import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/study_plan_bundle.dart';
import '../cubit/roadmap_gen_cubit.dart';
import '../cubit/roadmap_gen_state.dart';

/// AI 6 oylik reja: generatsiya animatsiyasi → tayyor xulosa.
class RoadmapGeneratingPage extends StatelessWidget {
  const RoadmapGeneratingPage({
    super.key,
    required this.onReady,
  });

  final ValueChanged<StudyPlanBundle> onReady;

  static const _steps = [
    AppStrings.roadmapStepAnalyze,
    AppStrings.roadmapStepWeak,
    AppStrings.roadmapStepWeeks,
    AppStrings.roadmapStepLessons,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoadmapGenCubit, RoadmapGenState>(
      listenWhen: (p, c) =>
          c.errorMessage != null && c.errorMessage != p.errorMessage,
      listener: (context, state) {
        if (state.errorMessage == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: state.phase == RoadmapGenPhase.ready && state.bundle != null
                  ? _ReadyView(
                      key: const ValueKey('ready'),
                      bundle: state.bundle!,
                      onOpen: () => onReady(state.bundle!),
                    )
                  : _GeneratingView(
                      key: const ValueKey('gen'),
                      progressStep: state.progressStep,
                      steps: _steps,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({
    super.key,
    required this.progressStep,
    required this.steps,
  });

  final int progressStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            AppStrings.roadmapGeneratingTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.roadmapGeneratingBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 36),
          Center(
            child: SizedBox(
              width: 88,
              height: 88,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: AppColors.accent,
                backgroundColor: AppColors.surfaceAlt,
                value: (progressStep / steps.length).clamp(0.05, 1.0),
              ),
            ),
          ),
          const SizedBox(height: 36),
          ...List.generate(steps.length, (i) {
            final done = progressStep > i;
            final active = progressStep == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle
                        : active
                            ? Icons.autorenew
                            : Icons.circle_outlined,
                    color: done
                        ? AppColors.success
                        : active
                            ? AppColors.accent
                            : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: done || active
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          Text(
            '${AppConstants.studyPlanMonths} ${AppStrings.roadmapMonths} · '
            '${AppConstants.studyPlanWeeks} ${AppStrings.roadmapWeeks}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    super.key,
    required this.bundle,
    required this.onOpen,
  });

  final StudyPlanBundle bundle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final plan = bundle.plan;
    final firstWeeks = plan.weeks.take(4).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.successSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.route, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.roadmapReadyTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.roadmapReadyBody,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _StatBox(
              value: '${AppConstants.studyPlanMonths}',
              label: AppStrings.roadmapMonths,
            ),
            const SizedBox(width: 10),
            _StatBox(
              value: '${plan.totalWeeks}',
              label: AppStrings.roadmapWeeks,
            ),
            const SizedBox(width: 10),
            _StatBox(
              value: '${bundle.lessons.length}',
              label: AppStrings.roadmapLessons,
            ),
          ],
        ),
        if (plan.weakCategories.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            AppStrings.roadmapFocus,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.weakCategories
                .map(
                  (t) => Chip(
                    label: Text(t),
                    backgroundColor: AppColors.errorSoft,
                    labelStyle: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Dastlabki haftalar',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ...firstWeeks.map(
          (w) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: w.isExamWeek ? AppColors.accent : AppColors.surfaceAlt,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  w.isExamWeek ? Icons.quiz : Icons.menu_book_rounded,
                  color: w.isExamWeek ? AppColors.accent : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.titleUz,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        w.focusTopics.join(' · '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onOpen,
            child: const Text(AppStrings.roadmapOpenMap),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.accent,
                    fontSize: 28,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
