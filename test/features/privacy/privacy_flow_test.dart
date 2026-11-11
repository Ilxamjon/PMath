import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:pmath/features/privacy/domain/account_erasure.dart';
import 'package:pmath/features/privacy/domain/parent_consent.dart';
import 'package:pmath/features/privacy/domain/third_party_sdks.dart';
import 'package:pmath/features/proctoring/domain/proctoring_guard.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/auth_service.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/services/supabase_gateway.dart';
import 'package:pmath/services/vision_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Edge implements EdgeInvoker {
  _Edge({this.ready = true, this.result});

  final bool ready;
  final FunctionResult? result;
  var calls = 0;

  @override
  bool get isReady => ready;

  @override
  Future<FunctionResult?> invoke(
    String name,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    calls += 1;
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rozilik holati va vaqti profilga yoziladi', () {
    final at = DateTime.utc(2026, 11, 11, 8);
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade4,
      targetSchool: 'Prezident maktabi',
      parentPhone: '+998901234567',
      createdAt: at,
      parentConsentGranted: false,
      parentConsentAt: at,
    );
    final again = UserModel.fromJson(user.toJson());
    expect(again.parentConsentGranted, isFalse);
    expect(again.parentConsentAt, at);
    expect(parentAllowsCamera(again), isFalse);
    expect(parentAllowsCamera(again.copyWith(parentConsentGranted: true)), isTrue);
  });

  test('onboarding rad etilsa kamera yopiq, rozilik saqlanadi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final cubit = OnboardingCubit(
      authService: StubAuthService(),
      storageService: storage,
    );

    cubit.chooseConsent(false);
    cubit.setName('Ali');
    cubit.submitName();
    cubit.submitGrade();
    cubit.setSchool('Prezident');
    cubit.submitSchool();
    cubit.setPhoneLocal('901234567');
    await cubit.sendOtp();
    cubit.setOtp('1234');
    await cubit.verifyOtpAndFinish();

    final saved = storage.getUser();
    expect(saved?.parentConsentGranted, isFalse);
    expect(saved?.parentConsentAt, isNotNull);
    expect(parentAllowsCamera(saved), isFalse);
    await cubit.close();
  });

  test('server o‘chmasa lokal ma’lumot qoladi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final at = DateTime.utc(2026, 11, 11);
    await storage.completeOnboarding(
      UserModel(
        id: 'u1',
        studentName: 'Ali',
        grade: StudentGrade.grade3,
        targetSchool: 'PM',
        parentPhone: '+998901234567',
        createdAt: at,
        parentConsentGranted: true,
        parentConsentAt: at,
      ),
    );
    final edge = _Edge(
      result: const FunctionResult(statusCode: 503, json: {'error': 'unavailable'}),
    );
    final outcome = await AccountErasure(
      storage: storage,
      auth: StubAuthService(),
      gateway: edge,
      deleteFiles: () async {},
    ).erase();

    expect(outcome, ErasureOutcome.serverFailed);
    expect(edge.calls, 1);
    expect(storage.getUser()?.studentName, 'Ali');
  });

  test('server va lokal ma’lumot o‘chadi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final at = DateTime.utc(2026, 11, 11);
    await storage.saveUser(
      UserModel(
        id: 'u1',
        studentName: 'Ali',
        grade: StudentGrade.grade3,
        targetSchool: 'PM',
        parentPhone: '+998901234567',
        createdAt: at,
        parentConsentGranted: true,
        parentConsentAt: at,
      ),
    );
    await storage.setOnboardingDone(true);
    var files = 0;
    final outcome = await AccountErasure(
      storage: storage,
      auth: StubAuthService(),
      gateway: _Edge(
        result: const FunctionResult(statusCode: 200, json: {'ok': true}),
      ),
      deleteFiles: () async {
        files += 1;
      },
    ).erase();

    expect(outcome, ErasureOutcome.deleted);
    expect(files, 1);
    expect(storage.getUser(), isNull);
    expect(storage.isOnboardingDone, isFalse);
  });

  test('server hisobi yo‘q bo‘lsa faqat telefon tozalanadi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final at = DateTime.utc(2026, 11, 11);
    await storage.saveUser(
      UserModel(
        id: 'u1',
        studentName: 'Ali',
        grade: StudentGrade.grade3,
        targetSchool: 'PM',
        parentPhone: '+998901234567',
        createdAt: at,
        parentConsentGranted: true,
        parentConsentAt: at,
      ),
    );
    final edge = _Edge(ready: false);
    final outcome = await AccountErasure(
      storage: storage,
      auth: StubAuthService(),
      gateway: edge,
      deleteFiles: () async {},
    ).erase();

    expect(outcome, ErasureOutcome.localOnly);
    expect(edge.calls, 0);
    expect(storage.getUser(), isNull);
  });

  test('rozilik yo‘q bo‘lsa proctoring kamera ochmaydi', () {
    final guard = LocalProctoringGuard(cameraAllowed: () => false);
    guard.startSession(lessonId: 'lesson-1');
    expect(guard.isActive, isFalse);
    expect(guard.cameraController, isNull);
  });

  test('proctoring kadrni yozmaydi va yubormaydi', () {
    final source = File(
      'lib/features/proctoring/domain/proctoring_guard.dart',
    ).readAsStringSync();
    expect(source.contains('http'), isFalse);
    expect(source.contains('supabase'), isFalse);
    expect(source.contains('writeAsBytes'), isFalse);
    expect(source.contains('File('), isFalse);
    expect(source.contains('takePicture'), isFalse);
    expect(source.contains('upload'), isFalse);
  });

  test('rozilik yo‘q bo‘lsa daftar rasmi yuborilmaydi', () async {
    final edge = _Edge();
    final service = RemoteVisionAiService(
      gateway: edge,
      allowUpload: () => false,
      encode: (_) async => [1, 2, 3],
      deleteFile: (_) async {},
    );

    await expectLater(
      service.analyzeNotebookPage(
        imagePath: 'page.jpg',
        homework: HomeworkModel.demo(),
      ),
      throwsA(isA<VisionAnalysisException>()),
    );
    expect(edge.calls, 0);
  });

  test('pubspec dagi ziddiyatli kutubxonalar belgilangan', () {
    final conflict = thirdPartySdks
        .where((sdk) => sdk.risk == KidsStoreRisk.conflict)
        .map((sdk) => sdk.package);
    expect(conflict, containsAll(['google_fonts', 'speech_to_text']));
    expect(
      thirdPartySdks.any(
        (sdk) =>
            sdk.package.contains('firebase') ||
            sdk.package.contains('admob') ||
            sdk.package.contains('facebook'),
      ),
      isFalse,
    );

    final fn = File('supabase/functions/delete-account/index.ts').readAsStringSync();
    expect(fn, contains('gate.userId'));
    expect(fn, contains('deleteUser(gate.userId)'));
  });
}
