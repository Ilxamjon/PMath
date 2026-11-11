import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/lesson_model.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../diagnostic/presentation/widgets/question_card.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../../proctoring/presentation/widgets/proctoring_camera_pip.dart';
import '../../../proctoring/presentation/widgets/proctoring_warning_dialog.dart';
import '../../../subscription/presentation/pages/paywall_page.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';

/// Prezident maktabi uslubidagi mini-imtihon.
class ExamPage extends StatelessWidget {
  const ExamPage({
    super.key,
    required this.lesson,
    required this.userId,
  });

  final LessonModel lesson;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ExamCubit(
        lesson: lesson,
        storage: ctx.read<StorageService>(),
        userId: userId,
        proctoring: ctx.read<ProctoringGuard>(),
        parentAlerts: ctx.read<ParentAlertService>(),
      )..loadIntro(),
      child: const _ExamView(),
    );
  }
}

class _ExamView extends StatelessWidget {
  const _ExamView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExamCubit, ExamState>(
      listenWhen: (p, c) =>
          (c.errorMessage != null && c.errorMessage != p.errorMessage) ||
          (c.showProctoringDialog && !p.showProctoringDialog),
      listener: (context, state) async {
        if (state.showProctoringDialog &&
            state.pauseReason != null &&
            state.pauseReason!.isViolation) {
          context.read<ExamCubit>().clearProctoringDialogFlag();
          await showProctoringWarningDialog(
            context,
            reason: state.pauseReason!,
            warningCount: state.proctoringWarnings,
            onResume: () =>
                context.read<ExamCubit>().resumeAfterProctoring(),
          );
          return;
        }
        if (state.errorMessage == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: state.errorMessage == AppStrings.examTimeUp
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
                ExamPhase.intro => _IntroView(
                    key: const ValueKey('intro'),
                    lesson: state.lesson,
                    questionCount: state.totalQuestions,
                  ),
                ExamPhase.quiz => _QuizView(
                    key: const ValueKey('quiz'),
                    state: state,
                  ),
                ExamPhase.results => _ResultsView(
                    key: const ValueKey('results'),
                    state: state,
                  ),
              },
            ),
          ),
        );
      },
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({
    super.key,
    required this.lesson,
    required this.questionCount,
  });

  final LessonModel lesson;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.examBadge,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson.titleUz,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.examIntroBody
                .replaceAll('{n}', '$questionCount')
                .replaceAll('{m}', '${AppConstants.examDurationMinutes}'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          _Bullet(AppStrings.examRule1),
          _Bullet(AppStrings.examRule2),
          _Bullet(AppStrings.examRule3),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.read<ExamCubit>().startQuiz(),
              child: const Text(AppStrings.examStart),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({super.key, required this.state});

  final ExamState state;

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    final progress =
        state.totalQuestions == 0 ? 0.0 : (state.currentIndex + 1) / state.totalQuestions;
    final lowTime = state.remainingSeconds <= 60;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 8,
                  percent: progress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.surfaceAlt,
                  progressColor: AppColors.accent,
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: state.isProctoringPaused
                      ? AppColors.errorSoft
                      : lowTime
                          ? AppColors.errorSoft
                          : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  state.isProctoringPaused
                      ? AppStrings.proctoringPaused
                      : state.timerLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: state.isProctoringPaused || lowTime
                        ? AppColors.error
                        : AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.examQuestion} ${state.currentIndex + 1}/${state.totalQuestions}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (context.read<ProctoringGuard>().isActive)
                ProctoringCameraPip(
                  guard: context.read<ProctoringGuard>(),
                  onLongPressSimulate: () =>
                      context.read<ExamCubit>().simulateProctoringViolation(),
                ),
            ],
          ),
        ),
        if (state.isProctoringPaused)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.pauseReason?.bodyUz ?? AppStrings.proctoringPaused,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        Expanded(
          child: AbsorbPointer(
            absorbing: state.isProctoringPaused,
            child: Opacity(
              opacity: state.isProctoringPaused ? 0.45 : 1,
              child: q == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        QuestionCard(question: q),
                        const SizedBox(height: 16),
                        ...q.options.map((opt) {
                          final selected = state.currentSelection == opt;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: selected
                                  ? AppColors.accentSoft
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => context
                                    .read<ExamCubit>()
                                    .selectAnswer(opt),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.accent
                                          : AppColors.surfaceAlt,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    opt,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.proctoringSimulateHint,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.isLoading || state.isProctoringPaused
                    ? null
                    : () => context.read<ExamCubit>().submitCurrentAndNext(),
                child: Text(
                  state.isLastQuestion
                      ? AppStrings.examFinish
                      : AppStrings.continueBtn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({super.key, required this.state});

  final ExamState state;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final pct = (result.overallPercent / 100).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          AppStrings.examReportTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          result.titleUz,
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
            progressColor: MasteryHelper.colorFor(result.overallPercent),
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
                  AppStrings.examScore,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _InfoTile(
          label: AppStrings.examCorrect,
          value: '${result.correctCount}/${result.totalQuestions}',
        ),
        _InfoTile(
          label: AppStrings.examTimeSpent,
          value: _formatDuration(result.durationSeconds),
        ),
        _InfoTile(
          label: AppStrings.examCoins,
          value: '+${result.coinsEarned}',
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.examLeagueTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.league.emoji} ${result.league.labelUz}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.examRank
                    .replaceAll('{rank}', '${result.estimatedRank}')
                    .replaceAll('{pool}', '${result.peerPool}'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ),
        if (result.categoryScores.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            AppStrings.examByCategory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...result.categoryScores.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(e.key.labelUz)),
                  Text(
                    '${e.value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: MasteryHelper.colorFor(e.value),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: state.nextUnlocked
                ? AppColors.successSoft
                : AppColors.accentSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            state.nextUnlocked
                ? AppStrings.examUnlocked
                : state.unlockBlockedBy == LockBlockReason.subscriptionRequired
                    ? AppStrings.practiceBlockedSubscription
                    : AppStrings.examNeedMastery,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: state.nextUnlocked
                      ? AppColors.success
                      : AppColors.accentDark,
                ),
          ),
        ),
        if (state.unlockBlockedBy == LockBlockReason.subscriptionRequired) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallPage()),
              );
            },
            child: const Text(AppStrings.subscriptionGateCta),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.examBackToMap),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
