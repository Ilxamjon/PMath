import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../diagnostic/data/diagnostic_repository.dart';
import '../../diagnostic/presentation/cubit/diagnostic_cubit.dart';
import '../../diagnostic/presentation/pages/diagnostic_page.dart';
import '../../home/presentation/pages/main_shell.dart';
import '../../study_plan/data/study_plan_repository.dart';
import '../../study_plan/presentation/cubit/roadmap_gen_cubit.dart';
import '../../study_plan/presentation/pages/roadmap_generating_page.dart';
import 'cubit/onboarding_cubit.dart';
import 'pages/onboarding_page.dart';

enum _AppGate { loading, onboarding, diagnostic, roadmap, home }

/// Ilova: Onboarding → Diagnostik → AI Roadmap → Dashboard.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  UserModel? _user;
  var _gate = _AppGate.loading;

  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _resolveGate();
  }

  Future<void> _resolveGate() async {
    final storage = context.read<StorageService>();
    var saved = storage.getUser();

    if (storage.isOnboardingDone && saved != null) {
      try {
        final fresh = await context
            .read<AuthService>()
            .refreshAccess(saved)
            .timeout(const Duration(seconds: 8));
        if (!mounted) return;
        if (fresh != null) {
          saved = fresh;
          await storage.saveUser(fresh);
        }
      } catch (_) {}
    }

    if (!mounted) return;

    if (!storage.isOnboardingDone || saved == null) {
      setState(() {
        _user = null;
        _gate = _AppGate.onboarding;
      });
      return;
    }

    _user = saved;

    if (!storage.isDiagnosticDone) {
      setState(() => _gate = _AppGate.diagnostic);
      return;
    }

    if (!storage.hasStudyPlan) {
      setState(() => _gate = _AppGate.roadmap);
      return;
    }

    setState(() => _gate = _AppGate.home);
  }

  void _onOnboardingCompleted(UserModel user) {
    setState(() {
      _user = user;
      _gate = _AppGate.diagnostic;
    });
  }

  void _onDiagnosticCompleted() {
    setState(() => _gate = _AppGate.roadmap);
  }

  void _onRoadmapReady() {
    setState(() => _gate = _AppGate.home);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_gate) {
      _AppGate.loading => const _Splash(),
      _AppGate.onboarding => BlocProvider(
          create: (context) => OnboardingCubit(
            authService: context.read<AuthService>(),
            storageService: context.read<StorageService>(),
          ),
          child: OnboardingPage(onCompleted: _onOnboardingCompleted),
        ),
      _AppGate.diagnostic => BlocProvider(
          create: (context) => DiagnosticCubit(
            repository: context.read<DiagnosticRepository>(),
            userId: _user!.id,
          )..loadIntro(),
          child: DiagnosticPage(
            user: _user!,
            onCompleted: (_) => _onDiagnosticCompleted(),
          ),
        ),
      _AppGate.roadmap => _RoadmapGate(
          user: _user!,
          onReady: _onRoadmapReady,
        ),
      _AppGate.home => MainShell(user: _user!),
    };
  }
}

class _RoadmapGate extends StatelessWidget {
  const _RoadmapGate({required this.user, required this.onReady});

  final UserModel user;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    final diagnostic =
        context.read<StorageService>().getDiagnosticResult();

    if (diagnostic == null) {
      // Diagnostika yo‘q — xavfsizlik uchun qayta diagnostika.
      return Center(
        child: Text(
          AppStrings.somethingWrong,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return BlocProvider(
      create: (context) => RoadmapGenCubit(
        repository: context.read<StudyPlanRepository>(),
        userId: user.id,
      )..generate(diagnostic),
      child: RoadmapGeneratingPage(onReady: (_) => onReady()),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
