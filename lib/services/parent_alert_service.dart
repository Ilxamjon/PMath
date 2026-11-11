import 'package:uuid/uuid.dart';

import '../models/homework_model.dart';
import '../models/parent_alert_log.dart';
import '../models/user_model.dart';
import 'storage_service.dart';
import 'supabase_gateway.dart';

enum _SendOutcome { sent, notLinked, failed }

/// Ota-ona ogohlantirishlari — Telegram Bot + lokal jurnal.
abstract class ParentAlertService {
  Future<void> homeworkAssigned({
    required UserModel user,
    required HomeworkModel homework,
  });

  Future<void> homeworkOverdue({
    required UserModel user,
    required HomeworkModel homework,
  });

  Future<void> streakAtRisk({
    required UserModel user,
    required String reasonUz,
  });

  Future<void> homeworkGraded({
    required UserModel user,
    required HomeworkModel homework,
  });

  Future<void> cheatingWarning({
    required UserModel user,
    required String reasonUz,
    required int totalWarnings,
  });

  /// Ota-ona panelidan test xabar.
  Future<ParentAlertLogEntry> sendTestMessage({required UserModel user});

  List<ParentAlertLogEntry> get recentLogs;

  bool get isTelegramConfigured;
}

/// Stub — faqat xotira log (testlar uchun).
class StubParentAlertService implements ParentAlertService {
  final List<ParentAlertLogEntry> sentLog = [];
  final _uuid = const Uuid();

  @override
  List<ParentAlertLogEntry> get recentLogs => List.unmodifiable(sentLog);

  @override
  bool get isTelegramConfigured => false;

  ParentAlertLogEntry _add(ParentAlertType type, String message) {
    final entry = ParentAlertLogEntry(
      id: _uuid.v4(),
      type: type,
      messageUz: message,
      createdAt: DateTime.now(),
      channel: 'local',
      delivered: true,
    );
    sentLog.insert(0, entry);
    return entry;
  }

  @override
  Future<void> homeworkAssigned({
    required UserModel user,
    required HomeworkModel homework,
  }) async {
    _add(
      ParentAlertType.homeworkAssigned,
      'ASSIGN → ${user.parentPhone}: ${homework.titleUz}',
    );
  }

  @override
  Future<void> homeworkOverdue({
    required UserModel user,
    required HomeworkModel homework,
  }) async {
    _add(
      ParentAlertType.homeworkOverdue,
      'OVERDUE → ${user.parentPhone}: ${homework.titleUz}',
    );
  }

  @override
  Future<void> streakAtRisk({
    required UserModel user,
    required String reasonUz,
  }) async {
    _add(ParentAlertType.streakAtRisk, 'STREAK → ${user.parentPhone}: $reasonUz');
  }

  @override
  Future<void> homeworkGraded({
    required UserModel user,
    required HomeworkModel homework,
  }) async {
    _add(
      ParentAlertType.homeworkGraded,
      'GRADED → ${homework.titleUz} ${homework.masteryPercent.toStringAsFixed(0)}%',
    );
  }

  @override
  Future<void> cheatingWarning({
    required UserModel user,
    required String reasonUz,
    required int totalWarnings,
  }) async {
    _add(
      ParentAlertType.cheating,
      'CHEAT → $reasonUz (jami: $totalWarnings)',
    );
  }

  @override
  Future<ParentAlertLogEntry> sendTestMessage({required UserModel user}) async {
    return _add(
      ParentAlertType.testMessage,
      'Test xabar → ${user.parentPhone}',
    );
  }
}

/// Production: Telegram Bot API + SharedPreferences jurnal.
class TelegramParentAlertService implements ParentAlertService {
  TelegramParentAlertService({
    required StorageService storage,
    EdgeInvoker? gateway,
    Uuid? uuid,
  })  : _storage = storage,
        _gateway = gateway,
        _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final EdgeInvoker? _gateway;
  final Uuid _uuid;

  @override
  List<ParentAlertLogEntry> get recentLogs => _storage.getParentAlertLogs();

  @override
  bool get isTelegramConfigured =>
      (_gateway?.isReady ?? false) &&
      (_resolveChatId(_storage.getUser())?.isNotEmpty ?? false);

  String? _resolveChatId(UserModel? user) {
    final fromUser = user?.telegramChatId?.trim();
    if (fromUser == null || fromUser.isEmpty) return null;
    return fromUser;
  }

  Future<ParentAlertLogEntry> _dispatch({
    required UserModel user,
    required ParentAlertType type,
    required String messageUz,
  }) async {
    final chatId = _resolveChatId(user);
    var channel = 'local';
    var delivered = false;
    String? error;

    if ((_gateway?.isReady ?? false) && chatId != null) {
      try {
        final outcome = await _sendTelegram(
          text: _formatTelegram(user: user, type: type, body: messageUz),
        );
        if (outcome == _SendOutcome.sent) {
          channel = 'telegram';
          delivered = true;
        } else if (outcome == _SendOutcome.notLinked) {
          channel = 'local';
          delivered = true;
          await _clearChatId();
        } else {
          channel = 'telegram';
          delivered = false;
          error = 'Telegram yuborilmadi';
        }
      } catch (e) {
        channel = 'telegram';
        error = e.toString();
        delivered = false;
      }
    } else {
      // Chat ulanmagan yoki bulut yo‘q — lokal jurnal.
      channel = 'local';
      delivered = true;
    }

    final entry = ParentAlertLogEntry(
      id: _uuid.v4(),
      type: type,
      messageUz: messageUz,
      createdAt: DateTime.now(),
      channel: channel,
      delivered: delivered,
      error: error,
    );
    await _storage.appendParentAlertLog(entry);
    return entry;
  }

  String _formatTelegram({
    required UserModel user,
    required ParentAlertType type,
    required String body,
  }) {
    return '${type.iconHint} <b>PMath · ${type.labelUz}</b>\n'
        '👤 ${user.studentName} (${user.grade.labelUz})\n'
        '📱 ${user.parentPhone}\n\n'
        '$body';
  }

  Future<void> _clearChatId() async {
    final user = _storage.getUser();
    if (user == null || user.telegramChatId == null) return;
    await _storage.saveUser(user.copyWith(clearTelegramChatId: true));
  }

  Future<_SendOutcome> _sendTelegram({required String text}) async {
    final gateway = _gateway;
    if (gateway == null) return _SendOutcome.failed;
    final result = await gateway.invoke(
      'telegram-notify',
      {'text': text},
      timeout: const Duration(seconds: 12),
    );
    if (result != null &&
        result.statusCode == 200 &&
        result.json?['ok'] == true) {
      return _SendOutcome.sent;
    }
    if (result?.statusCode == 409 && result?.json?['error'] == 'not_linked') {
      return _SendOutcome.notLinked;
    }
    return _SendOutcome.failed;
  }

  @override
  Future<void> homeworkAssigned({
    required UserModel user,
    required HomeworkModel homework,
  }) async {
    final due = homework.dueAt;
    final dueLabel = due == null
        ? '—'
        : '${due.day.toString().padLeft(2, '0')}.${due.month.toString().padLeft(2, '0')}';
    await _dispatch(
      user: user,
      type: ParentAlertType.homeworkAssigned,
      messageUz:
          'Yangi uyga vazifa: «${homework.titleUz}». Muddat: $dueLabel.',
    );
  }

  @override
  Future<void> homeworkOverdue({
    required UserModel user,
    required HomeworkModel homework,
  }) async {
    await _dispatch(
      user: user,
      type: ParentAlertType.homeworkOverdue,
      messageUz:
          '⚠️ «${homework.titleUz}» muddati o‘tdi. Iltimos, bolangizni eslating — streak yo‘qolishi mumkin.',
    );
  }

  @override
  Future<void> streakAtRisk({
    required UserModel user,
    required String reasonUz,
  }) async {
    await _dispatch(
      user: user,
      type: ParentAlertType.streakAtRisk,
      messageUz:
          '🔥 Streak xavf ostida (${user.streakDays} kun). $reasonUz',
    );
  }

  @override
  Future<void> homeworkGraded({
    required UserModel user,
    required HomeworkModel homework,
  }) async {
    await _dispatch(
      user: user,
      type: ParentAlertType.homeworkGraded,
      messageUz:
          '«${homework.titleUz}» baholandi: ${homework.masteryPercent.toStringAsFixed(0)}%.',
    );
  }

  @override
  Future<void> cheatingWarning({
    required UserModel user,
    required String reasonUz,
    required int totalWarnings,
  }) async {
    await _dispatch(
      user: user,
      type: ParentAlertType.cheating,
      messageUz:
          'Nazorat: $reasonUz. Jami ogohlantirishlar: $totalWarnings.',
    );
  }

  @override
  Future<ParentAlertLogEntry> sendTestMessage({required UserModel user}) {
    return _dispatch(
      user: user,
      type: ParentAlertType.testMessage,
      messageUz:
          'Bu PMath test xabari. Telegram ulanishi ishlayapti ✅',
    );
  }
}
