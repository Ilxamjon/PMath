import '../models/user_model.dart';

/// OTP yoki tarmoq xatosi. UI o‘zbekcha matnga aylantiradi.
enum AuthFailureKind { network, invalidCode }

class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthFailureKind kind;
}

/// Auth servis abstraksiyasi.
abstract class AuthService {
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String code);
  Future<void> signOut();
  String? get currentUserId;

  /// OTP dan keyin profil. Sinov sanalari serverdan keladi.
  Future<UserModel> completeSignUp({
    required String studentName,
    required StudentGrade grade,
    required String targetSchool,
    required String parentPhone,
    required int welcomeCoins,
    required bool parentConsentGranted,
    required DateTime parentConsentAt,
  });

  /// Allaqachon ochilgan profilga rozilik qarorini yozadi.
  Future<void> saveParentConsent({
    required bool granted,
    required DateTime at,
  });

  /// Keshlangan foydalanuvchini server holati bilan yangilaydi.
  Future<UserModel?> refreshAccess(UserModel cached);
}

/// Lokal stub. Faqat debug va Supabase sozlanmaganda ishlatiladi.
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
    final normalized = normalizeUzPhone(phone);
    assert(normalized.length >= 12);
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final ok = code.trim().length >= 4;
    if (ok) {
      _userId = 'local_${normalizeUzPhone(phone)}';
    }
    return ok;
  }

  @override
  Future<void> signOut() async {
    _userId = null;
  }

  @override
  Future<UserModel> completeSignUp({
    required String studentName,
    required StudentGrade grade,
    required String targetSchool,
    required String parentPhone,
    required int welcomeCoins,
    required bool parentConsentGranted,
    required DateTime parentConsentAt,
  }) async {
    final now = DateTime.now();
    return UserModel(
      id: currentUserId ?? 'local_${normalizeUzPhone(parentPhone)}',
      studentName: studentName,
      grade: grade,
      targetSchool: targetSchool,
      parentPhone: normalizeUzPhone(parentPhone),
      createdAt: now,
      lastActiveDate: now,
      subscriptionStatus: SubscriptionStatus.trial,
      trialStartedAt: now,
      subscriptionExpiresAt: now.add(const Duration(days: 7)),
      serverNowAtFetch: now,
      deviceObservedAt: now,
      coins: welcomeCoins,
      level: 1,
      streakDays: 1,
      parentConsentGranted: parentConsentGranted,
      parentConsentAt: parentConsentAt,
    );
  }

  @override
  Future<void> saveParentConsent({
    required bool granted,
    required DateTime at,
  }) async {}

  @override
  Future<UserModel?> refreshAccess(UserModel cached) async => cached;
}
