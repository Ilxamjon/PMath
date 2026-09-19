import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/homework_model.dart';
import '../../../../services/tts_service.dart';
import '../../domain/error_analysis_coach.dart';
import '../cubit/error_analysis_cubit.dart';

/// Interaktiv xato tahlili — Sokratik yo‘naltirish.
class ErrorAnalysisPage extends StatelessWidget {
  const ErrorAnalysisPage({super.key, required this.homework});

  final HomeworkModel homework;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ErrorAnalysisCubit(
        homework: homework,
        tts: ctx.read<TtsService>(),
      )..start(),
      child: const _ErrorAnalysisView(),
    );
  }
}

class _ErrorAnalysisView extends StatelessWidget {
  const _ErrorAnalysisView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ErrorAnalysisCubit, ErrorAnalysisState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.errorAnalysisTitle),
            actions: [
              if (!state.finished && state.current != null)
                IconButton(
                  tooltip: AppStrings.errorAnalysisListen,
                  onPressed: state.isSpeaking
                      ? () => context.read<ErrorAnalysisCubit>().stopSpeak()
                      : () => context.read<ErrorAnalysisCubit>().speakExplain(),
                  icon: Icon(
                    state.isSpeaking ? Icons.stop_circle : Icons.volume_up,
                  ),
                ),
            ],
          ),
          body: state.finished
              ? _FinishedBody(total: state.total)
              : state.items.isEmpty
                  ? const _EmptyBody()
                  : _ActiveBody(state: state),
        );
      },
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 56, color: AppColors.success),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorAnalysisNoErrors,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppStrings.gradingDone),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishedBody extends StatelessWidget {
  const _FinishedBody({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology_alt, size: 64, color: AppColors.accent),
          const SizedBox(height: 20),
          Text(
            AppStrings.errorAnalysisDoneTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            total == 0
                ? AppStrings.errorAnalysisNoErrors
                : AppStrings.errorAnalysisDoneBody.replaceAll('{n}', '$total'),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppStrings.errorAnalysisRewrite),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.gradingToMap),
          ),
        ],
      ),
    );
  }
}

class _ActiveBody extends StatelessWidget {
  const _ActiveBody({required this.state});

  final ErrorAnalysisState state;

  @override
  Widget build(BuildContext context) {
    final item = state.current!;
    final progress = (state.index + 1) / state.total;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.surfaceAlt,
          color: AppColors.accent,
          minHeight: 4,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${AppStrings.errorAnalysisProgress} ${state.index + 1}/${state.total}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                item.titleUz,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              _StudentCard(step: item.source.studentStep),
              const SizedBox(height: 16),
              ..._phaseWidgets(context, state, item),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    context.read<ErrorAnalysisCubit>().continuePhase(),
                child: Text(_ctaLabel(state)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _phaseWidgets(
    BuildContext context,
    ErrorAnalysisState state,
    AnalyzedError item,
  ) {
    switch (state.phase) {
      case ErrorStepPhase.explain:
        return [
          _InfoCard(
            title: AppStrings.errorAnalysisWhy,
            body: item.simpleExplainUz,
            color: AppColors.errorSoft,
            titleColor: AppColors.error,
          ),
        ];
      case ErrorStepPhase.socratic:
        return [
          _InfoCard(
            title: AppStrings.errorAnalysisThink,
            body: item.nudgeUz,
            color: AppColors.accentSoft,
            titleColor: AppColors.accentDark,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.errorAnalysisQuestions,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...item.socraticQuestions.asMap().entries.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceAlt),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ];
      case ErrorStepPhase.softHint:
        return [
          _InfoCard(
            title: AppStrings.errorAnalysisSoftHint,
            body: item.softHintUz ?? AppStrings.errorAnalysisSoftHintFallback,
            color: AppColors.successSoft,
            titleColor: AppColors.success,
          ),
        ];
      case ErrorStepPhase.fullHint:
        return [
          _InfoCard(
            title: AppStrings.errorAnalysisFullHint,
            body: item.fullHintUz ?? '—',
            color: AppColors.primary.withValues(alpha: 0.08),
            titleColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.errorAnalysisRewriteHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ];
    }
  }

  String _ctaLabel(ErrorAnalysisState state) {
    return switch (state.phase) {
      ErrorStepPhase.explain => AppStrings.errorAnalysisGoThink,
      ErrorStepPhase.socratic => AppStrings.errorAnalysisShowHint,
      ErrorStepPhase.softHint =>
        state.current?.fullHintUz != null &&
                state.current!.fullHintUz!.isNotEmpty
            ? AppStrings.errorAnalysisShowAnswer
            : AppStrings.errorAnalysisNextError,
      ErrorStepPhase.fullHint => state.hasNextError
          ? AppStrings.errorAnalysisNextError
          : AppStrings.errorAnalysisFinish,
    };
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.step});

  final String step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.errorAnalysisYourStep,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            step,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.color,
    required this.titleColor,
  });

  final String title;
  final String body;
  final Color color;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
