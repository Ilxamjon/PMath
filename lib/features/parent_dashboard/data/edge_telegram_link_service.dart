import '../../../services/storage_service.dart';
import '../../../services/supabase_gateway.dart';
import '../domain/telegram_link_service.dart';

class EdgeTelegramLinkService implements TelegramLinkService {
  EdgeTelegramLinkService({
    required EdgeInvoker gateway,
    required StorageService storage,
  })  : _gateway = gateway,
        _storage = storage;

  final EdgeInvoker _gateway;
  final StorageService _storage;

  @override
  bool get isCloudReady => _gateway.isReady;

  @override
  Future<TelegramLinkSession?> startLink() async {
    if (!_gateway.isReady) return null;
    final result = await _gateway.invoke('telegram-link', <String, dynamic>{});
    if (result == null || result.statusCode != 200) return null;
    final code = result.json?['code'];
    final url = result.json?['url'];
    if (code is! String || url is! String) return null;
    final uri = telegramBotUri(url, code);
    if (uri == null) return null;
    return TelegramLinkSession(code: code, url: uri);
  }

  @override
  Future<TelegramLinkStatus> refresh() async {
    if (!_gateway.isReady) return const TelegramLinkStatus.offline();
    final result = await _gateway.invoke('telegram-status', <String, dynamic>{});
    if (result == null || result.statusCode != 200) {
      return const TelegramLinkStatus.offline();
    }
    final linked = result.json?['linked'] == true;
    final raw = result.json?['chatId'];
    final chatId = raw is String && RegExp(r'^-?\d{1,20}$').hasMatch(raw)
        ? raw
        : null;
    final connected = linked && chatId != null;
    await _write(connected ? chatId : null);
    return TelegramLinkStatus(
      reachable: true,
      linked: connected,
      chatId: connected ? chatId : null,
    );
  }

  Future<void> _write(String? chatId) async {
    final user = _storage.getUser();
    if (user == null) return;
    await _storage.saveUser(
      user.copyWith(
        telegramChatId: chatId,
        clearTelegramChatId: chatId == null,
      ),
    );
  }
}
