/// Auth servis abstraksiyasi — keyinchalik Supabase Phone SMS bilan to‘ldiriladi.
abstract class AuthService {
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String code);
  Future<void> signOut();
  String? get currentUserId;
}

/// Hozircha lokal stub (development).
///
/// Production: `Supabase.instance.client.auth.signInWithOtp(phone: phone)`
/// va `verifyOTP(type: OtpType.sms, ...)`.
class StubAuthService implements AuthService {
  String? _userId;

  @override
  String? get currentUserId => _userId;

  /// +998XXXXXXXXX formatiga keltirish.
  static String normalizeUzPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998') && digits.length == 12) {
      return '+$digits';
    }
    if (digits.length == 9) return '+998$digits';
    if (phone.trim().startsWith('+')) return phone.trim();
    return '+998$digits';
  }

  @override
  Future<void> sendOtp(String phone) async {
    // TODO: await Supabase.instance.client.auth.signInWithOtp(
    //   phone: normalizeUzPhone(phone),
    // );
    final normalized = normalizeUzPhone(phone);
    assert(normalized.length >= 12);
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    // TODO: final res = await Supabase.instance.client.auth.verifyOTP(
    //   phone: normalizeUzPhone(phone),
    //   token: code,
    //   type: OtpType.sms,
    // );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final ok = code.trim().length >= 4;
    if (ok) {
      _userId = 'local_${normalizeUzPhone(phone)}';
    }
    return ok;
  }

  @override
  Future<void> signOut() async {
    // TODO: await Supabase.instance.client.auth.signOut();
    _userId = null;
  }
}
