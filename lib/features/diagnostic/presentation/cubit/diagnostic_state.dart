import 'package:equatable/equatable.dart';

import '../../../../models/diagnostic_result_model.dart';
import '../../../../models/question_model.dart';

enum DiagnosticPhase { intro, quiz, results }

class DiagnosticState extends Equatable {
  const DiagnosticState({
    this.phase = DiagnosticPhase.intro,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.currentSelection,
    this.remainingSeconds = 0,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final DiagnosticPhase phase;
  final List<QuestionModel> questions;
  final int currentIndex;

  /// questionId → tanlangan javob matni.
  final Map<String, String> selectedAnswers;
  final String? currentSelection;
  final int remainingSeconds;
  final bool isLoading;
  final DiagnosticResultModel? result;
  final String? errorMessage;

  QuestionModel? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length
          ? null
          : questions[currentIndex];

  int get totalQuestions => questions.length;

  double get progress =>
      totalQuestions == 0 ? 0 : (currentIndex + 1) / totalQuestions;

  bool get isLastQuestion =>
      totalQuestions > 0 && currentIndex >= totalQuestions - 1;

  bool get canSubmitCurrent =>
      currentSelection != null && currentSelection!.isNotEmpty;

  String get timerLabel {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isTimeLow => remainingSeconds <= 60;

  DiagnosticState copyWith({
    DiagnosticPhase? phase,
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<String, String>? selectedAnswers,
    String? currentSelection,
    bool clearSelection = false,
    int? remainingSeconds,
    bool? isLoading,
    DiagnosticResultModel? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiagnosticState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentSelection:
          clearSelection ? null : (currentSelection ?? this.currentSelection),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        phase,
        questions,
        currentIndex,
        selectedAnswers,
        currentSelection,
        remainingSeconds,
        isLoading,
        result,
        errorMessage,
      ];
}
