/// Telegram Bot sozlamalari.
///
/// Tokenni build vaqtida bering:
/// `flutter run --dart-define=TELEGRAM_BOT_TOKEN=123:ABC`
///
/// Chat ID ota-ona panelidan saqlanadi (yoki `--dart-define=TELEGRAM_CHAT_ID=`).
abstract final class TelegramConfig {
  static const botToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
    defaultValue: '',
  );

  static const defaultChatId = String.fromEnvironment(
    'TELEGRAM_CHAT_ID',
    defaultValue: '',
  );

  static bool get hasBotToken => botToken.trim().isNotEmpty;

  static String apiUrl(String method) =>
      'https://api.telegram.org/bot$botToken/$method';
}
