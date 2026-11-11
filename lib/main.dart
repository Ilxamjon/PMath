import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/diagnostic/data/diagnostic_repository.dart';
import 'features/grading/domain/ai_grading_service.dart';
import 'features/homework/data/homework_service.dart';
import 'features/onboarding/presentation/app_bootstrap.dart';
import 'features/proctoring/domain/proctoring_guard.dart';
import 'features/study_plan/data/study_plan_repository.dart';
import 'features/study_plan/domain/ai_study_plan_generator.dart';
import 'services/ai_tutor_service.dart';
import 'services/auth_service.dart';
import 'services/parent_alert_service.dart';
import 'services/storage_service.dart';
import 'services/supabase_gateway.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
import 'services/vision_ai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final storage = await StorageService.init();
  final gateway = SupabaseGateway();
  await gateway.ensureSession();
  final auth = StubAuthService();
  final diagnosticRepo = LocalDiagnosticRepository(storage);
  final studyPlanRepo = LocalStudyPlanRepository(
    storage: storage,
    generator: LocalAiStudyPlanGenerator(),
  );
  final tts = FlutterTtsService();
  final stt = DeviceSttService();
  final proctoring = LocalProctoringGuard();
  final parentAlerts = TelegramParentAlertService(
    storage: storage,
    gateway: gateway,
  );
  final homeworkService = HomeworkService(
    storage: storage,
    alerts: parentAlerts,
  );
  final visionAi = EdgeVisionAiService(gateway: gateway);
  final tutor = AiTutorService(gateway: gateway);
  final gradingAi = LocalAiGradingService();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storage),
        RepositoryProvider<AuthService>.value(value: auth),
        RepositoryProvider<DiagnosticRepository>.value(value: diagnosticRepo),
        RepositoryProvider<StudyPlanRepository>.value(value: studyPlanRepo),
        RepositoryProvider<TtsService>.value(value: tts),
        RepositoryProvider<SttService>.value(value: stt),
        RepositoryProvider<ProctoringGuard>.value(value: proctoring),
        RepositoryProvider<ParentAlertService>.value(value: parentAlerts),
        RepositoryProvider<AiTutorService>.value(value: tutor),
        RepositoryProvider<HomeworkService>.value(value: homeworkService),
        RepositoryProvider<VisionAiService>.value(value: visionAi),
        RepositoryProvider<AiGradingService>.value(value: gradingAi),
      ],
      child: const PMathApp(),
    ),
  );
}

/// PMath — Prezident va ixtisoslashgan maktablar uchun math tutor.
class PMathApp extends StatelessWidget {
  const PMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppBootstrap(),
    );
  }
}
