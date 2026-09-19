import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/question_model.dart';
import '../../../homework/presentation/pages/homework_detail_page.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../../proctoring/presentation/widgets/proctoring_camera_pip.dart';
import '../../../proctoring/presentation/widgets/proctoring_warning_dialog.dart';
import '../../../subscription/presentation/pages/paywall_page.dart';
import '../cubit/practice_cubit.dart';
import '../cubit/practice_state.dart';

/// Gamified tushuncha mashqi — 15 savol (5/5/5) + proctoring.
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PracticeCubit, PracticeState>(
      listenWhen: (p, c) => c.showProctoringDialog && !p.showProctoringDialog,
      listener: (context, state) async {
        if (!state.showProctoringDialog || state.pauseReason == null) return;
        context.read<PracticeCubit>().clearProctoringDialogFlag();
        await showProctoringWarningDialog(
          context,
          reason: state.pauseReason!,
          warningCount: state.proctoringWarnings,
          onResume: () =>
              context.read<PracticeCubit>().resumeAfterProctoring(),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.practiceTitle),
            automaticallyImplyLeading: state.phase == PracticePhase.results,
            actions: [
              if (state.proctoringActive)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(
                      state.isProctoringPaused
                          ? Icons.warning_amber
                          : Icons.videocam,
                      size: 16,
                      color: state.isProctoringPaused
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    label: Text(
                      state.isProctoringPaused
                          ? AppStrings.proctoringPaused
                          : AppStrings.lessonProctoringOn,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    backgroundColor: state.isProctoringPaused
                        ? AppColors.errorSoft
                        : AppColors.successSoft,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (state.proctoringActive)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProctoringCameraPip(
                    guard: context.read<ProctoringGuard>(),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.isProctoringPaused,
              child: Opacity(
                opacity: state.isProctoringPaused ? 0.5 : 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: switch (state.phase) {
                    PracticePhase.quiz ||
                    PracticePhase.feedback =>
                      _QuizView(
                        key: ValueKey(state.currentIndex),
                        state: state,
                      ),
                    PracticePhase.results => _ResultsView(
                        key: const ValueKey('results'),
                        state: state,
                      ),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({super.key, required this.state});

  final PracticeState state;

  Color _diffColor(QuestionDifficulty d) => switch (d) {
        QuestionDifficulty.easy => AppColors.success,
        QuestionDifficulty.medium => AppColors.accentDark,
        QuestionDifficulty.hard => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    if (q == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final showingFeedback = state.phase == PracticePhase.feedback;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.practiceQuestion} ${state.currentIndex + 1}/${state.total}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _diffColor(q.difficulty).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.difficulty.labelUz,
                  style: TextStyle(
                    color: _diffColor(q.difficulty),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CoinBadge(coins: state.coinsEarned),
              if (state.combo >= 2) ...[
                const SizedBox(width: 8),
                _ComboBadge(combo: state.combo),
              ],
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.prompt,
                        style: Theme.of(context).textTheme.titleLarge),
                    if (q.latexFormula != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Math.tex(
                          q.latexFormula!,
                          mathStyle: MathStyle.display,
                          textStyle: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...q.options.map((opt) {
                final selected = state.selectedAnswer == opt;
                Color border = AppColors.surfaceAlt;
                Color bg = AppColors.surface;
                if (showingFeedback) {
                  if (opt == q.correctAnswer) {
                    border = AppColors.success;
                    bg = AppColors.successSoft;
                  } else if (selected) {
                    border = AppColors.error;
                    bg = AppColors.errorSoft;
                  }
                } else if (selected) {
                  border = AppColors.accent;
                  bg = AppColors.accentSoft;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: showingFeedback
                        ? null
                        : () =>
                            context.read<PracticeCubit>().selectAnswer(opt),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: 2),
                      ),
                      child: Text(
                        opt,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                );
              }),
              if (showingFeedback) ...[
                const SizedBox(height: 8),
                Text(
                  state.lastAnswerCorrect == true
                      ? AppStrings.practiceCorrect
                      : AppStrings.practiceWrong,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: state.lastAnswerCorrect == true
                            ? AppColors.success
                            : AppColors.error,
                      ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: showingFeedback
                  ? () =>
                      context.read<PracticeCubit>().continueAfterFeedback()
                  : (state.selectedAnswer == null
                      ? null
                      : () => context.read<PracticeCubit>().submitAnswer()),
              child: Text(
                    showingFeedback
                    ? (state.isLast
                        ? AppStrings.practiceFinish
                        : AppStrings.continueBtn)
                    : AppStrings.practiceSelect,
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

  final PracticeState state;

  @override
  Widget build(BuildContext context) {
    final hwCount = state.assignedHomeworkList.length;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircularPercentIndicator(
            radius: 64,
            lineWidth: 10,
            percent: (state.masteryPercent / 100).clamp(0.0, 1.0),
            center: Text(
              '${state.masteryPercent.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            progressColor: state.masteryPercent >= 80
                ? AppColors.success
                : AppColors.accent,
            backgroundColor: AppColors.surfaceAlt,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.practiceResults,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _StatRow(
          label: AppStrings.practiceMastery,
          value: '${state.correctCount}/${state.total}',
        ),
        _StatRow(
          label: AppStrings.coinsLabel,
          value: '+${state.coinsEarned}',
        ),
        _StatRow(
          label: AppStrings.masteryPercent,
          value:
              '${state.masteryPercent.toStringAsFixed(0)}% · ${MasteryHelper.masteryLabelUz(state.masteryPercent)}',
        ),
        const SizedBox(height: 8),
        Text(
          state.nextUnlocked
              ? AppStrings.practiceUnlocked
              : AppStrings.practiceLockedStill,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: state.nextUnlocked
                    ? AppColors.success
                    : AppColors.accentDark,
              ),
        ),
        if (state.unlockBlockedBy == LockBlockReason.subscriptionRequired) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallPage()),
                );
              },
              child: const Text(AppStrings.subscriptionGateCta),
            ),
          ),
        ],
        if (hwCount > 0) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeworkAssigned,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '$hwCount ta uyga vazifa berildi (5 oson, 5 o‘rtacha, 5 qiyin). '
                  'Daftarga yozib, Skaner orqali topshiring.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<PracticeCubit>().openScannerTab();
                      if (!context.mounted) return;
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.document_scanner),
                    label: const Text(AppStrings.homeworkGoScan),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HomeworkDetailPage(
                            homework: state.assignedHomeworkList.first,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text(AppStrings.homeworkView),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (!state.nextUnlocked) ...[
          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.read<PracticeCubit>().retry(),
              child: const Text(AppStrings.practiceRetry),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.practiceBackToMap),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('🪙 $coins',
          style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _ComboBadge extends StatelessWidget {
  const _ComboBadge({required this.combo});
  final int combo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('🔥 x$combo',
          style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
