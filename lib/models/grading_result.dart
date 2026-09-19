import 'package:equatable/equatable.dart';

import 'homework_model.dart';

/// Bitta qadamning bahosi.
class GradedStep extends Equatable {
  const GradedStep({
    required this.stepIndex,
    required this.studentStep,
    required this.isCorrect,
    this.explanationUz,
    this.correctHintUz,
  });

  final int stepIndex;
  final String studentStep;
  final bool isCorrect;
  final String? explanationUz;
  final String? correctHintUz;

  HomeworkErrorStep? toErrorStep() {
    if (isCorrect) return null;
    return HomeworkErrorStep(
      stepIndex: stepIndex,
      studentStep: studentStep,
      explanationUz: explanationUz ?? 'Bu qadamda xato bor.',
      correctHintUz: correctHintUz,
    );
  }

  @override
  List<Object?> get props =>
      [stepIndex, studentStep, isCorrect, explanationUz, correctHintUz];
}

/// AI baholash yakuni.
class GradingResult extends Equatable {
  const GradingResult({
    required this.masteryPercent,
    required this.steps,
    required this.coinsEarned,
    required this.feedbackUz,
    required this.modelName,
    this.expectedSteps = const [],
  });

  final double masteryPercent;
  final List<GradedStep> steps;
  final int coinsEarned;
  final String feedbackUz;
  final String modelName;
  final List<String> expectedSteps;

  int get correctCount => steps.where((s) => s.isCorrect).length;

  int get errorCount => steps.where((s) => !s.isCorrect).length;

  bool get isPassed => masteryPercent >= 80.0;

  List<HomeworkErrorStep> get errorSteps => steps
      .map((s) => s.toErrorStep())
      .whereType<HomeworkErrorStep>()
      .toList();

  @override
  List<Object?> get props =>
      [masteryPercent, steps, coinsEarned, feedbackUz, modelName, expectedSteps];
}
