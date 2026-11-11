/// Ilovada qoladigan yagona bulut sozlamalari.
///
/// Kalit va bot token bu yerda emas — ular Supabase secrets ichida.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}
