import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/diagnostic/data/diagnostic_repository.dart';
import 'package:pmath/features/grading/domain/ai_grading_service.dart';
import 'package:pmath/features/homework/data/homework_service.dart';
import 'package:pmath/features/proctoring/domain/proctoring_guard.dart';
import 'package:pmath/features/study_plan/data/study_plan_repository.dart';
import 'package:pmath/features/study_plan/domain/ai_study_plan_generator.dart';
import 'package:pmath/main.dart';
import 'package:pmath/services/ai_tutor_service.dart';
import 'package:pmath/services/auth_service.dart';
import 'package:pmath/services/parent_alert_service.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/services/stt_service.dart';
import 'package:pmath/services/tts_service.dart';
import 'package:pmath/services/vision_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<RepositoryProvider<dynamic>>> providers() async {
    final storage = await StorageService.init();
    final alerts = StubParentAlertService();
    return [
      RepositoryProvider<StorageService>.value(value: storage),
      RepositoryProvider<AuthService>.value(value: StubAuthService()),
      RepositoryProvider<DiagnosticRepository>.value(
        value: LocalDiagnosticRepository(storage),
      ),
      RepositoryProvider<StudyPlanRepository>.value(
        value: LocalStudyPlanRepository(
          storage: storage,
          generator: LocalAiStudyPlanGenerator(),
        ),
      ),
      RepositoryProvider<TtsService>.value(value: StubTtsService()),
      RepositoryProvider<SttService>.value(value: StubSttService()),
      RepositoryProvider<ProctoringGuard>.value(value: StubProctoringGuard()),
      RepositoryProvider<ParentAlertService>.value(value: alerts),
      RepositoryProvider<AiTutorService>.value(value: AiTutorService()),
      RepositoryProvider<HomeworkService>.value(
        value: HomeworkService(storage: storage, alerts: alerts),
      ),
      RepositoryProvider<VisionAiService>.value(value: StubVisionAiService()),
      RepositoryProvider<AiGradingService>.value(
        value: LocalAiGradingService(),
      ),
    ];
  }

  testWidgets('Onboarding welcome ekrani ochiladi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repos = await providers();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: repos,
        child: const PMathApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PMath'), findsWidgets);
    expect(find.text('Boshlash'), findsOneWidget);
  });
}
