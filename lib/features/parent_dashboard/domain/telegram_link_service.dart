/// Serverdan kelgan bir martalik ulash havolasi.
class TelegramLinkSession {
  const TelegramLinkSession({required this.code, required this.url});

  final String code;
  final Uri url;
}

/// Serverdagi ulanish holati.
class TelegramLinkStatus {
  const TelegramLinkStatus({
    required this.reachable,
    required this.linked,
    this.chatId,
  });

  const TelegramLinkStatus.offline()
      : reachable = false,
        linked = false,
        chatId = null;

  final bool reachable;
  final bool linked;
  final String? chatId;
}

/// Ota-ona Telegramini bir martalik kod bilan ulash.
abstract class TelegramLinkService {
  bool get isCloudReady;

  Future<TelegramLinkSession?> startLink();

  /// Serverdagi chat_id ni o‘qiydi va lokal foydalanuvchiga yozadi.
  Future<TelegramLinkStatus> refresh();
}

/// `https://t.me/<bot>?start=<8 belgi>`. Boshqa manzil ochilmaydi.
Uri? telegramBotUri(String raw, String code) {
  if (!RegExp(r'^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$').hasMatch(code)) {
    return null;
  }
  final uri = Uri.tryParse(raw);
  if (uri == null) return null;
  if (uri.scheme != 'https' || uri.host != 't.me') return null;
  if (uri.queryParameters['start'] != code) return null;
  if (uri.userInfo.isNotEmpty || uri.pathSegments.length != 1) return null;
  final name = uri.pathSegments.single;
  if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]{3,31}$').hasMatch(name)) return null;
  return uri;
}
