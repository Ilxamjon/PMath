import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_service.dart';

/// `my_subscription()` qatori. Qurilma soati bu yerda yo‘q.
class ServerSubscription {
  const ServerSubscription({
    required this.trialStartedAt,
    required this.expiresAt,
    required this.serverNow,
    required this.hasAccess,
  });

  final DateTime trialStartedAt;
  final DateTime expiresAt;
  final DateTime serverNow;
  final bool hasAccess;
}

/// Supabase chaqiruvlari. Testlar shu shartnomani mock qiladi.
abstract class OtpGateway {
  Future<void> sendSms(String phone);
  Future<bool> verifySms(String phone, String code);
  Future<void> signOut();
  String? get userId;

  Future<ServerSubscription> createProfile({
    required String studentName,
    required int grade,
    required String targetSchool,
    required String parentPhone,
    required bool parentConsentGranted,
    required DateTime parentConsentAt,
  });

  Future<void> saveConsent({
    required bool granted,
    required DateTime at,
  });

  Future<ServerSubscription?> fetchSubscription();
}

class LiveOtpGateway implements OtpGateway {
  LiveOtpGateway({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _db => _client ?? Supabase.instance.client;

  @override
  String? get userId => _db.auth.currentUser?.id;

  @override
  Future<void> sendSms(String phone) async {
    try {
      final current = _db.auth.currentUser;
      if (current != null && current.isAnonymous) {
        await _db.auth.signOut();
      }
      await _db.auth.signInWithOtp(phone: phone);
    } catch (error) {
      throw _asFailure(error);
    }
  }

  @override
  Future<bool> verifySms(String phone, String code) async {
    try {
      final response = await _db.auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );
      return response.session != null;
    } on AuthException catch (error) {
      if (_isNetwork(error)) throw const AuthFailure(AuthFailureKind.network);
      return false;
    } catch (error) {
      if (error is AuthFailure) rethrow;
      throw _asFailure(error);
    }
  }

  @override
  Future<void> signOut() => _db.auth.signOut();

  @override
  Future<void> saveConsent({
    required bool granted,
    required DateTime at,
  }) async {
    final id = userId;
    if (id == null) return;
    try {
      await _db.from('profiles').update({
        'parent_consent_granted': granted,
        'parent_consent_at': at.toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (error) {
      throw _asFailure(error);
    }
  }

  @override
  Future<ServerSubscription> createProfile({
    required String studentName,
    required int grade,
    required String targetSchool,
    required String parentPhone,
    required bool parentConsentGranted,
    required DateTime parentConsentAt,
  }) async {
    final id = userId;
    if (id == null) throw const AuthFailure(AuthFailureKind.network);
    try {
      await _db.from('profiles').upsert(
        {
          'id': id,
          'student_name': studentName,
          'grade': grade,
          'target_school': targetSchool,
          'parent_phone': parentPhone,
          'parent_consent_granted': parentConsentGranted,
          'parent_consent_at': parentConsentAt.toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
      final row = await fetchSubscription();
      if (row == null) throw const AuthFailure(AuthFailureKind.network);
      return row;
    } catch (error) {
      if (error is AuthFailure) rethrow;
      throw _asFailure(error);
    }
  }

  @override
  Future<ServerSubscription?> fetchSubscription() async {
    if (userId == null) return null;
    try {
      final raw = await _db.rpc('my_subscription');
      return _parseSubscription(raw);
    } catch (error) {
      throw _asFailure(error);
    }
  }

  ServerSubscription? _parseSubscription(dynamic raw) {
    Map<String, dynamic>? row;
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      row = Map<String, dynamic>.from(raw.first as Map);
    } else if (raw is Map) {
      row = Map<String, dynamic>.from(raw);
    }
    if (row == null) return null;
    return ServerSubscription(
      trialStartedAt: DateTime.parse(row['trial_started_at'].toString()),
      expiresAt: DateTime.parse(row['subscription_expires_at'].toString()),
      serverNow: DateTime.parse(row['server_now'].toString()),
      hasAccess: row['has_access'] == true,
    );
  }

  AuthFailure _asFailure(Object error) {
    if (error is AuthFailure) return error;
    if (_isNetwork(error)) return const AuthFailure(AuthFailureKind.network);
    return const AuthFailure(AuthFailureKind.unavailable);
  }

  bool _isNetwork(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('socket') ||
        text.contains('network') ||
        text.contains('failed host') ||
        text.contains('connection') ||
        text.contains('timed out');
  }
}

/// Haqiqiy telefon OTP. Release build shu servisni ishlatadi.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService({OtpGateway? gateway})
      : _gateway = gateway ?? LiveOtpGateway();

  final OtpGateway _gateway;

  @override
  String? get currentUserId => _gateway.userId;

  @override
  Future<void> sendOtp(String phone) {
    return _gateway.sendSms(StubAuthService.normalizeUzPhone(phone));
  }

  @override
  Future<bool> verifyOtp(String phone, String code) {
    return _gateway.verifySms(
      StubAuthService.normalizeUzPhone(phone),
      code.trim(),
    );
  }

  @override
  Future<void> signOut() => _gateway.signOut();

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
    final phone = StubAuthService.normalizeUzPhone(parentPhone);
    final server = await _gateway.createProfile(
      studentName: studentName,
      grade: grade.number,
      targetSchool: targetSchool,
      parentPhone: phone,
      parentConsentGranted: parentConsentGranted,
      parentConsentAt: parentConsentAt,
    );
    return _userFromServer(
      id: currentUserId ?? '',
      studentName: studentName,
      grade: grade,
      targetSchool: targetSchool,
      parentPhone: phone,
      welcomeCoins: welcomeCoins,
      server: server,
      parentConsentGranted: parentConsentGranted,
      parentConsentAt: parentConsentAt,
    );
  }

  @override
  Future<void> saveParentConsent({
    required bool granted,
    required DateTime at,
  }) {
    return _gateway.saveConsent(granted: granted, at: at);
  }

  @override
  Future<UserModel?> refreshAccess(UserModel cached) async {
    final server = await _gateway.fetchSubscription();
    if (server == null) return cached;
    return cached.copyWith(
      trialStartedAt: server.trialStartedAt,
      subscriptionExpiresAt: server.expiresAt,
      serverNowAtFetch: server.serverNow,
      deviceObservedAt: DateTime.now(),
      subscriptionStatus: _statusFor(server),
    );
  }

  UserModel _userFromServer({
    required String id,
    required String studentName,
    required StudentGrade grade,
    required String targetSchool,
    required String parentPhone,
    required int welcomeCoins,
    required ServerSubscription server,
    required bool parentConsentGranted,
    required DateTime parentConsentAt,
  }) {
    final observed = DateTime.now();
    return UserModel(
      id: id,
      studentName: studentName,
      grade: grade,
      targetSchool: targetSchool,
      parentPhone: parentPhone,
      createdAt: server.trialStartedAt,
      lastActiveDate: observed,
      subscriptionStatus: _statusFor(server),
      trialStartedAt: server.trialStartedAt,
      subscriptionExpiresAt: server.expiresAt,
      serverNowAtFetch: server.serverNow,
      deviceObservedAt: observed,
      coins: welcomeCoins,
      level: 1,
      streakDays: 1,
      parentConsentGranted: parentConsentGranted,
      parentConsentAt: parentConsentAt,
    );
  }

  SubscriptionStatus _statusFor(ServerSubscription server) {
    if (!server.hasAccess) return SubscriptionStatus.expired;
    final trialEnd = server.trialStartedAt.add(const Duration(days: 7, hours: 1));
    if (server.expiresAt.isAfter(trialEnd)) return SubscriptionStatus.active;
    return SubscriptionStatus.trial;
  }
}

/// Supabase manzili yo‘q bo‘lsa SMS chaqirilmaydi — lokal kod bilan davom etiladi.
/// Testlar haqiqiy yo‘lni `gateway` orqali beradi.
AuthService createAuthService({
  required bool allowStub,
  required bool supabaseConfigured,
  OtpGateway? gateway,
}) {
  if (!supabaseConfigured && (allowStub || gateway == null)) {
    return StubAuthService();
  }
  return SupabaseAuthService(gateway: gateway);
}
