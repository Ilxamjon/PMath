import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/diagnostic_result_model.dart';
import '../../../../models/user_model.dart';
import '../cubit/diagnostic_cubit.dart';
import '../cubit/diagnostic_state.dart';
import '../widgets/question_card.dart';

/// Diagnostik test: intro → quiz → results.
class DiagnosticPage extends StatelessWidget {
  const DiagnosticPage({
    super.key,
    required this.user,
    required this.onCompleted,
  });

  final UserModel user;
  final ValueChanged<DiagnosticResultModel> onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiagnosticCubit, DiagnosticState>(
      listenWhen: (p, c) =>
          c.errorMessage != null && c.errorMessage != p.errorMessage,
      listener: (context, state) {
        if (state.errorMessage == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: state.errorMessage == AppStrings.diagnosticTimeUp
                ? AppColors.warning
                : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: switch (state.phase) {
                DiagnosticPhase.intro => _IntroView(
                    key: const ValueKey('intro'),
                    questionCount: state.totalQuestions,
                  ),
                DiagnosticPhase.quiz => _QuizView(
                    key: const ValueKey('quiz'),
                    state: state,
                  ),
                DiagnosticPhase.results => _ResultsView(
                    key: const ValueKey('results'),
                    result: state.result!,
                    studentName: user.studentName,
                    onContinue: () => onCompleted(state.result!),
                  ),
              },
            ),
          ),
        );
      },
    );
  }
}

// —— Intro ——

class _IntroView extends StatelessWidget {
  const _IntroView({super.key, required this.questionCount});

  final int questionCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.diagnosticTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentDark,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.diagnosticIntroTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.diagnosticIntroBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceAlt),
            ),
            child: Text(
              AppStrings.diagnosticRules,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _InfoChip(icon: Icons.quiz_rounded, label: '$questionCount savol'),
              const SizedBox(width: 10),
              const _InfoChip(icon: Icons.timer_outlined, label: '10 daq'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.read<DiagnosticCubit>().startQuiz(),
              child: const Text(AppStrings.diagnosticStart),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// —— Quiz ——

class _QuizView extends StatelessWidget {
  const _QuizView({super.key, required this.state});

  final DiagnosticState state;

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    if (q == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.diagnosticQuestion} ${state.currentIndex + 1}/${state.totalQuestions}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _TimerBadge(
                label: state.timerLabel,
                isLow: state.isTimeLow,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearPercentIndicator(
            lineHeight: 8,
            percent: state.progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceAlt,
            progressColor: AppColors.accent,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                QuestionCard(question: q),
                const SizedBox(height: 20),
                AnswerOptions(
                  options: q.options,
                  selected: state.currentSelection,
                  onSelected: context.read<DiagnosticCubit>().selectAnswer,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () =>
                      context.read<DiagnosticCubit>().submitCurrentAndNext(),
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(
                      state.isLastQuestion
                          ? AppStrings.diagnosticFinish
                          : AppStrings.diagnosticNext,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.label, required this.isLow});

  final String label;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLow ? AppColors.errorSoft : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isLow ? AppColors.error : AppColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isLow ? AppColors.error : AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// —— Results ——

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    super.key,
    required this.result,
    required this.studentName,
    required this.onContinue,
  });

  final DiagnosticResultModel result;
  final String studentName;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final pct = (result.overallPercent / 100).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          AppStrings.diagnosticResultsTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          studentName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        Center(
          child: CircularPercentIndicator(
            radius: 72,
            lineWidth: 12,
            percent: pct,
            progressColor: result.overallPercent >= 70
                ? AppColors.success
                : AppColors.accent,
            backgroundColor: AppColors.surfaceAlt,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${result.overallPercent.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  AppStrings.diagnosticOverall,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${result.correctCount} ${AppStrings.diagnosticCorrect} '
          '${result.totalCount} ${AppStrings.diagnosticOf}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.diagnosticCategoryScore,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...result.categoryScores.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(e.key)),
                    Text(
                      '${e.value.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: e.value < 60
                                ? AppColors.error
                                : e.value >= 80
                                    ? AppColors.success
                                    : AppColors.accentDark,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: (e.value / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.surfaceAlt,
                  progressColor: e.value < 60
                      ? AppColors.error
                      : e.value >= 80
                          ? AppColors.success
                          : AppColors.accent,
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _TopicSection(
          title: AppStrings.diagnosticStrong,
          topics: result.strongCategories,
          color: AppColors.success,
          soft: AppColors.successSoft,
          empty: AppStrings.diagnosticNoStrong,
        ),
        const SizedBox(height: 12),
        _TopicSection(
          title: AppStrings.diagnosticWeak,
          topics: result.weakCategories,
          color: AppColors.error,
          soft: AppColors.errorSoft,
          empty: AppStrings.diagnosticNoWeak,
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onContinue,
            child: const Text(AppStrings.diagnosticContinueRoadmap),
          ),
        ),
      ],
    );
  }
}

class _TopicSection extends StatelessWidget {
  const _TopicSection({
    required this.title,
    required this.topics,
    required this.color,
    required this.soft,
    required this.empty,
  });

  final String title;
  final List<String> topics;
  final Color color;
  final Color soft;
  final String empty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (topics.isEmpty)
            Text(empty, style: Theme.of(context).textTheme.bodyMedium)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      backgroundColor: soft,
                      labelStyle: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
