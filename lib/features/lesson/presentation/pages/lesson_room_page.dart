import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../homework/data/homework_service.dart';
import '../../../practice/presentation/cubit/practice_cubit.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../../proctoring/presentation/widgets/proctoring_camera_pip.dart';
import '../../../proctoring/presentation/widgets/proctoring_warning_dialog.dart';
import '../cubit/lesson_cubit.dart';
import '../cubit/lesson_state.dart';
import '../widgets/lesson_visual_card.dart';

/// Interaktiv AI dars xonasi — TTS + vizual + Sokratik usul + proctoring.
class LessonRoomPage extends StatelessWidget {
  const LessonRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonCubit, LessonState>(
      listenWhen: (p, c) => c.showProctoringDialog && !p.showProctoringDialog,
      listener: (context, state) async {
        if (!state.showProctoringDialog || state.pauseReason == null) return;
        context.read<LessonCubit>().clearProctoringDialogFlag();
        await showProctoringWarningDialog(
          context,
          reason: state.pauseReason!,
          warningCount: state.proctoringWarnings,
          onResume: () => context.read<LessonCubit>().resumeAfterProctoring(),
        );
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.phase == LessonPhase.completed,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await _confirmExit(context);
            if (leave && context.mounted) {
              await context.read<LessonCubit>().stopSpeaking();
              if (context.mounted) Navigator.of(context).pop(false);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text(AppStrings.lessonRoomTitle),
              actions: [
                if (state.proctoringActive)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onLongPress: () => context
                          .read<LessonCubit>()
                          .simulateProctoringViolation(),
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        backgroundColor: state.isProctoringPaused
                            ? AppColors.errorSoft
                            : AppColors.successSoft,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                if (state.proctoringActive)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ProctoringCameraPip(
                      guard: context.read<ProctoringGuard>(),
                      onLongPressSimulate: () => context
                          .read<LessonCubit>()
                          .simulateProctoringViolation(),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: AbsorbPointer(
                absorbing: state.isProctoringPaused,
                child: Opacity(
                  opacity: state.isProctoringPaused ? 0.5 : 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.lesson.titleUz,
                              style:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.lesson.topic} · ${state.phaseLabel}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                            LinearPercentIndicator(
                              lineHeight: 8,
                              percent: state.progress,
                              backgroundColor: AppColors.surfaceAlt,
                              progressColor: AppColors.accent,
                              barRadius: const Radius.circular(8),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: switch (state.phase) {
                            LessonPhase.intro => _IntroBody(
                                key: const ValueKey('intro'),
                                state: state,
                              ),
                            LessonPhase.socratic => _SocraticBody(
                                key: ValueKey('soc_${state.socraticIndex}'),
                                state: state,
                              ),
                            LessonPhase.summary => _SummaryBody(
                                key: const ValueKey('sum'),
                                state: state,
                              ),
                            LessonPhase.completed => _CompletedBody(
                                key: const ValueKey('done'),
                                state: state,
                              ),
                          },
                        ),
                      ),
                      if (state.phase != LessonPhase.completed)
                        _VoiceAssistantBar(state: state),
                      _BottomActions(state: state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<bool> _confirmExit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.lessonExitConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(AppStrings.lessonExitNo),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(AppStrings.lessonExitYes),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _CoachBubble extends StatelessWidget {
  const _CoachBubble({
    required this.text,
    required this.isSpeaking,
    this.badge,
  });

  final String text;
  final bool isSpeaking;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent,
                child: Text(
                  isSpeaking ? '🔊' : 'AI',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.lessonCoachName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
              ),
              if (badge != null) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textOnPrimary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _IntroBody extends StatelessWidget {
  const _IntroBody({super.key, required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _CoachBubble(
          text: state.script.introText,
          isSpeaking: state.isSpeaking,
          badge: AppStrings.lessonIntro,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            AppStrings.lessonSocraticHint,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentDark,
                ),
          ),
        ),
      ],
    );
  }
}

class _SocraticBody extends StatefulWidget {
  const _SocraticBody({super.key, required this.state});

  final LessonState state;

  @override
  State<_SocraticBody> createState() => _SocraticBodyState();
}

class _SocraticBodyState extends State<_SocraticBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.thoughtText);
  }

  @override
  void didUpdateWidget(covariant _SocraticBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.thoughtText != _controller.text &&
        (widget.state.isListening ||
            widget.state.lastHeardText != oldWidget.state.lastHeardText)) {
      _controller.text = widget.state.thoughtText;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${AppStrings.lessonSocratic} ${state.socraticIndex + 1}/${state.socraticTotal}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.accentDark,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            AppStrings.aiRoleBanner,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentDark,
                ),
          ),
        ),
        const SizedBox(height: 12),
        if (state.currentStep != null && state.currentStep!.hasVisual) ...[
          LessonVisualCard(step: state.currentStep!),
          const SizedBox(height: 12),
        ],
        _CoachBubble(
          text: state.currentPrompt,
          isSpeaking: state.isSpeaking && !state.hasVoiceReply,
        ),
        if (state.hasVoiceReply) ...[
          const SizedBox(height: 12),
          _CoachBubble(
            text: state.voiceReplyText,
            isSpeaking: state.isSpeaking,
            badge: AppStrings.voiceCoachReply,
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          onChanged: context.read<LessonCubit>().setThought,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppStrings.lessonThoughtHint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.surfaceAlt),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            suffixIcon: IconButton(
              tooltip: state.isListening
                  ? AppStrings.voiceMicStop
                  : AppStrings.voiceMicTooltip,
              onPressed: state.isProctoringPaused
                  ? null
                  : () => context.read<LessonCubit>().toggleVoiceAsk(),
              icon: Icon(
                state.isListening ? Icons.mic : Icons.mic_none_rounded,
                color: state.isListening ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          state.script.hintNudge,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}

class _VoiceAssistantBar extends StatelessWidget {
  const _VoiceAssistantBar({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonCubit>();
    final status = state.isListening
        ? AppStrings.voiceListening
        : (state.lastHeardText.isNotEmpty
            ? '${AppStrings.voiceYouSaid}: ${state.lastHeardText}'
            : AppStrings.voicePanelTitle);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: state.isListening ? AppColors.errorSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.isListening ? AppColors.error : AppColors.surfaceAlt,
          ),
        ),
        child: Row(
          children: [
            IconButton.filled(
              onPressed: state.isProctoringPaused ? null : cubit.toggleVoiceAsk,
              style: IconButton.styleFrom(
                backgroundColor:
                    state.isListening ? AppColors.error : AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
              icon: Icon(
                state.isListening ? Icons.stop_rounded : Icons.mic_rounded,
              ),
              tooltip: state.isListening
                  ? AppStrings.voiceMicStop
                  : AppStrings.voiceMicTooltip,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (state.hasVoiceReply && !state.isListening) ...[
                    const SizedBox(height: 4),
                    Text(
                      state.voiceReplyText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ] else if (state.voiceError != null)
                    Text(
                      AppStrings.voiceUnavailable,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    )
                  else if (!state.sttAvailable && !state.isListening)
                    Text(
                      AppStrings.voiceUnavailable,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    )
                  else
                    Text(
                      AppStrings.voiceAskHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({super.key, required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _CoachBubble(
          text: state.script.summaryText,
          isSpeaking: state.isSpeaking,
          badge: AppStrings.lessonSummary,
        ),
      ],
    );
  }
}

class _CompletedBody extends StatelessWidget {
  const _CompletedBody({super.key, required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 56,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.lessonDone,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '+${state.coinsAwarded} 🪙 ${AppStrings.lessonCoinsEarned}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accentDark,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.lessonPracticeSoon,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.state});

  final LessonState state;

  Future<void> _openPractice(BuildContext context, LessonState state) async {
    await context.read<LessonCubit>().stopSpeaking();
    if (!context.mounted) return;

    final storage = context.read<StorageService>();
    final homeworkService = context.read<HomeworkService>();
    final proctoring = context.read<ProctoringGuard>();
    ParentAlertService? alerts;
    try {
      alerts = context.read<ParentAlertService>();
    } catch (_) {}

    final practiceDone = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PracticeCubit(
            lesson: state.lesson,
            storage: storage,
            homeworkService: homeworkService,
            proctoring: proctoring,
            parentAlerts: alerts,
          )..start(),
          child: const PracticePage(),
        ),
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pop(practiceDone == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonCubit>();

    if (state.phase == LessonPhase.completed) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _openPractice(context, state),
                child: const Text(AppStrings.lessonGoPractice),
              ),
            ),
          ],
        ),
      );
    }

    final primaryLabel = switch (state.phase) {
      LessonPhase.intro => AppStrings.continueBtn,
      LessonPhase.socratic => state.isLastSocratic
          ? AppStrings.continueBtn
          : AppStrings.lessonNextPrompt,
      LessonPhase.summary => AppStrings.lessonFinishLesson,
      LessonPhase.completed => AppStrings.lessonGoPractice,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: state.isSpeaking ? cubit.stopSpeaking : cubit.speakCurrent,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
            ),
            icon: Icon(
              state.isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
            ),
            tooltip: state.isSpeaking
                ? AppStrings.lessonStopAudio
                : AppStrings.lessonReplay,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    state.isProctoringPaused ? null : cubit.advance,
                child: Text(
                  state.phase == LessonPhase.socratic
                      ? AppStrings.lessonIThought
                      : primaryLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
