import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/auth_service.dart';
import 'package:pmath/services/supabase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class _FakeGateway implements OtpGateway {
  _FakeGateway({this.server});

  ServerSubscription? server;
  var failNetwork = false;
  var acceptCode = '123456';
  var sends = 0;
  String? id;
  String? lastPhone;

  @override
  String? get userId => id;

  @override
  Future<void> sendSms(String phone) async {
    if (failNetwork) throw const AuthFailure(AuthFailureKind.network);
    sends += 1;
    lastPhone = phone;
  }

  @override
  Future<bool> verifySms(String phone, String code) async {
    if (failNetwork) throw const AuthFailure(AuthFailureKind.network);
    lastPhone = phone;
    if (code != acceptCode) return false;
    id = 'user-1';
    return true;
  }

  @override
  Future<void> signOut() async {
    id = null;
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
    final row = server;
    if (failNetwork || row == null || id == null) {
      throw const AuthFailure(AuthFailureKind.network);
    }
    return row;
  }

  @override
  Future<void> saveConsent({
    required bool granted,
    required DateTime at,
  }) async {}

  @override
  Future<ServerSubscription?> fetchSubscription() async => server;
}

void main() {
  test('release yo‘li stub qaytarmaydi', () {
    final auth = createAuthService(
      allowStub: false,
      supabaseConfigured: false,
      gateway: _FakeGateway(),
    );
    expect(auth, isA<SupabaseAuthService>());
  });

  test('debug va Supabase yo‘q bo‘lsa stub qoladi', () {
    final auth = createAuthService(
      allowStub: true,
      supabaseConfigured: false,
    );
    expect(auth, isA<StubAuthService>());
  });

  test('istalgan kod qabul qilinmaydi', () async {
    final gateway = _FakeGateway();
    final auth = SupabaseAuthService(gateway: gateway);

    final ok = await auth.verifyOtp('90 123 45 67', '0000');

    expect(ok, isFalse);
    expect(auth.currentUserId, isNull);
    expect(gateway.lastPhone, '+998901234567');
  });

  test('tarmoq xatosi AuthFailure bo‘ladi', () async {
    final gateway = _FakeGateway()..failNetwork = true;
    final auth = SupabaseAuthService(gateway: gateway);

    expect(
      auth.sendOtp('+998901234567'),
      throwsA(
        isA<AuthFailure>().having(
          (error) => error.kind,
          'kind',
          AuthFailureKind.network,
        ),
      ),
    );
  });

  test('profil muddati server javobidan olinadi', () async {
    final serverNow = DateTime.utc(2026, 11, 1);
    final gateway = _FakeGateway(
      server: ServerSubscription(
        trialStartedAt: serverNow,
        expiresAt: serverNow.add(const Duration(days: 2)),
        serverNow: serverNow,
        hasAccess: true,
      ),
    )..id = 'user-1';
    final auth = SupabaseAuthService(gateway: gateway);

    final user = await auth.completeSignUp(
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'Prezident maktabi',
      parentPhone: '901234567',
      welcomeCoins: 10,
      parentConsentGranted: true,
      parentConsentAt: serverNow,
    );

    expect(user.parentConsentGranted, isTrue);
    expect(user.parentConsentAt, serverNow);

    expect(user.subscriptionExpiresAt, gateway.server!.expiresAt);
    final atFetch = user.deviceObservedAt!;
    final days = user.trialDaysLeftAt(atFetch);
    expect(user.trialDaysLeftAt(atFetch.subtract(const Duration(days: 40))), days);
    expect(
      user.hasAccessAt(atFetch.add(const Duration(days: 5))),
      isFalse,
    );
  });

  test('OTP qayta yuborish 60 soniya yopiq', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final gateway = _FakeGateway();
    final auth = SupabaseAuthService(gateway: gateway);
    final cubit = OnboardingCubit(
      authService: auth,
      storageService: storage,
    );

    cubit.setPhoneLocal('901234567');
    await cubit.sendOtp();
    expect(gateway.sends, 1);
    expect(cubit.state.resendSecondsLeft, 60);

    await cubit.resendOtp();
    expect(gateway.sends, 1);
    expect(cubit.state.errorMessage, 'Qayta yuborish (60 s)');
    await cubit.close();
  });
}
