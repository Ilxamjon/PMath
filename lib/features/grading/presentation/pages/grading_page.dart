import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/homework_model.dart';
import '../../../error_analysis/presentation/pages/error_analysis_page.dart';
import '../../../homework/data/homework_service.dart';
import '../../domain/ai_grading_service.dart';
import '../cubit/grading_cubit.dart';

/// AI baholash: loading → mastery % + qadamlar + tangalar.
class GradingPage extends StatelessWidget {
  const GradingPage({super.key, required this.homework});

  final HomeworkModel homework;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => GradingCubit(
        homework: homework,
        gradingService: ctx.read<AiGradingService>(),
        homeworkService: ctx.read<HomeworkService>(),
      )..run(),
      child: const _GradingView(),
    );
  }
}

class _GradingView extends StatelessWidget {
  const _GradingView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GradingCubit, GradingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text(AppStrings.gradingTitle)),
          body: switch (state.phase) {
            GradingPhase.loading => const _LoadingBody(),
            GradingPhase.error => _ErrorBody(
                message: state.errorMessage ?? AppStrings.somethingWrong,
                onRetry: () => context.read<GradingCubit>().run(),
              ),
            GradingPhase.result => _ResultBody(state: state),
          },
        );
      },
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 24),
          Text(
            AppStrings.gradingAnalyzing,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.gradingAnalyzingHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.gradingRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.state});

  final GradingState state;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final mastery = result.masteryPercent;
    final passed = result.isPassed;
    final color = MasteryHelper.colorFor(mastery);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircularPercentIndicator(
            radius: 72,
            lineWidth: 12,
            percent: (mastery / 100).clamp(0.0, 1.0),
            progressColor: color,
            backgroundColor: AppColors.surfaceAlt,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${mastery.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                ),
                Text(
                  AppStrings.masteryPercent,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: passed ? AppColors.successSoft : AppColors.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passed
                    ? AppStrings.gradingPassed
                    : AppStrings.gradingNeedsRevision,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: passed
                          ? AppColors.success
                          : AppColors.accentDark,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                result.feedbackUz,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '+${result.coinsEarned} ${AppStrings.gradingCoins}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${result.correctCount}/${result.steps.length} '
                    '${AppStrings.gradingStepsOk}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (state.nextUnlocked) ...[
                const SizedBox(height: 10),
                Text(
                  AppStrings.gradingNextUnlocked,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.gradingStepsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...result.steps.map((step) {
          final ok = step.isCorrect;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ok ? AppColors.success.withValues(alpha: 0.4) : AppColors.error.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      ok ? Icons.check_circle : Icons.cancel,
                      color: ok ? AppColors.success : AppColors.error,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${step.stepIndex + 1}. ${step.studentStep}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (!ok && step.explanationUz != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    step.explanationUz!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                ],
                if (!ok && step.correctHintUz != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.gradingHint}: ${step.correctHintUz}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        if (result.errorCount > 0) ...[
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ErrorAnalysisPage(
                      homework: state.homework,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.psychology_alt),
              label: const Text(AppStrings.gradingOpenErrors),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              passed
                  ? AppStrings.gradingDone
                  : AppStrings.gradingBackRevise,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.gradingToMap),
        ),
      ],
    );
  }
}
