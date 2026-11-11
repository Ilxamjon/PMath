import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/parent_dashboard/data/edge_telegram_link_service.dart';
import 'package:pmath/features/parent_dashboard/domain/telegram_link_service.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/parent_alert_service.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/services/supabase_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeEdge implements EdgeInvoker {
  _FakeEdge(this._handler);

  final FunctionResult? Function(String name, Map<String, dynamic> body) _handler;
  var ready = true;
  final calls = <Map<String, dynamic>>[];

  @override
  bool get isReady => ready;

  @override
  Future<FunctionResult?> invoke(
    String name,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    calls.add({'name': name, ...body});
    return _handler(name, body);
  }
}

UserModel _user({String? chatId}) {
  final now = DateTime.utc(2026, 11, 11, 12);
  return UserModel(
    id: 'u1',
    studentName: 'Ali',
    grade: StudentGrade.grade4,
    targetSchool: 'Prezident maktabi',
    parentPhone: '+998901234567',
    createdAt: now,
    telegramChatId: chatId,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('havola faqat t.me va 8 belgili kod', () {
    final ok = telegramBotUri(
      'https://t.me/PMathBot?start=AB23CD45',
      'AB23CD45',
    );
    expect(ok?.host, 't.me');
    expect(
      telegramBotUri('https://evil.example/?start=AB23CD45', 'AB23CD45'),
      isNull,
    );
    expect(telegramBotUri('https://t.me/PMathBot?start=SHORT', 'SHORT'), isNull);
    expect(
      telegramBotUri('https://t.me/PMathBot?start=AB23CD45', 'ZZZZZZZZ'),
      isNull,
    );
  });

  test('server kodi bot havolasini qaytaradi, token yo‘q', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final edge = _FakeEdge((name, body) {
      expect(name, 'telegram-link');
      expect(body.containsKey('token'), isFalse);
      return FunctionResult(
        statusCode: 200,
        json: <String, dynamic>{
          'code': 'AB23CD45',
          'url': 'https://t.me/PMathBot?start=AB23CD45',
        },
      );
    });
    final service = EdgeTelegramLinkService(gateway: edge, storage: storage);
    final session = await service.startLink();
    expect(session?.code, 'AB23CD45');
    expect(session?.url.toString(), 'https://t.me/PMathBot?start=AB23CD45');
    expect(edge.calls.single['name'], 'telegram-link');
  });

  test('so‘rov ulangan chatni saqlaydi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    await storage.saveUser(_user());
    final edge = _FakeEdge(
      (_, _) => FunctionResult(
        statusCode: 200,
        json: <String, dynamic>{'linked': true, 'chatId': '998877'},
      ),
    );
    final service = EdgeTelegramLinkService(gateway: edge, storage: storage);
    final status = await service.refresh();
    expect(status.linked, isTrue);
    expect(storage.getUser()?.telegramChatId, '998877');
  });

  test('ulanmagan ogohlantirish lokal jurnalga tushadi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    await storage.saveUser(_user());
    final edge = _FakeEdge((_, _) => throw StateError('chaqirilmasin'));
    final alerts = TelegramParentAlertService(storage: storage, gateway: edge);
    await alerts.homeworkAssigned(
      user: storage.getUser()!,
      homework: HomeworkModel(
        id: 'hw-1',
        lessonId: 'l1',
        titleUz: 'Qo‘shish',
        assignedAt: DateTime.utc(2026, 11, 11),
      ),
    );
    final log = storage.getParentAlertLogs().single;
    expect(log.channel, 'local');
    expect(log.delivered, isTrue);
    expect(edge.calls, isEmpty);
    expect(alerts.isTelegramConfigured, isFalse);
  });

  test('server ulanmagan desa xabar lokal jurnalga tushadi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    await storage.saveUser(_user(chatId: '111'));
    final edge = _FakeEdge(
      (_, _) => FunctionResult(
        statusCode: 409,
        json: <String, dynamic>{'error': 'not_linked'},
      ),
    );
    final alerts = TelegramParentAlertService(storage: storage, gateway: edge);
    await alerts.homeworkAssigned(
      user: storage.getUser()!,
      homework: HomeworkModel(
        id: 'hw-1',
        lessonId: 'l1',
        titleUz: 'Qo‘shish',
        assignedAt: DateTime.utc(2026, 11, 11),
      ),
    );
    final log = storage.getParentAlertLogs().single;
    expect(log.channel, 'local');
    expect(edge.calls.single['name'], 'telegram-notify');
    expect(edge.calls.single.containsKey('chatId'), isFalse);
    expect(storage.getUser()?.telegramChatId, isNull);
  });

  test('webhook o‘zbekcha xato va secret sarlavhani o‘z ichiga oladi', () {
    final source = File(
      'supabase/functions/_shared/telegram.ts',
    ).readAsStringSync();
    final webhook = File(
      'supabase/functions/telegram-webhook/index.ts',
    ).readAsStringSync();
    expect(source, contains('Bu kod allaqachon ishlatilgan.'));
    expect(source, contains('Kod muddati tugagan. Ilovadan yangi kod oling.'));
    expect(source, contains('Ulandi ✅'));
    expect(webhook, contains('X-Telegram-Bot-Api-Secret-Token'));
    expect(webhook, contains('secretsMatch'));

    final lib = Directory('lib');
    final dart = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in dart) {
      final text = file.readAsStringSync();
      expect(text.contains('api.telegram.org'), isFalse, reason: file.path);
      expect(text.contains('TELEGRAM_BOT_TOKEN'), isFalse, reason: file.path);
    }
  });
}
