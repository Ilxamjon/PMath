import 'package:equatable/equatable.dart';

import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/exam_result_model.dart';
import '../../../../models/lesson_model.dart';
import '../../../../models/question_model.dart';
import '../../../proctoring/domain/proctoring_guard.dart';

enum ExamPhase { intro, quiz, results }

class ExamState extends Equatable {
  const ExamState({
    required this.lesson,
    this.phase = ExamPhase.intro,
    this.questions = const [],
    this.currentIndex = 0,
    this.currentSelection,
    this.selectedAnswers = const {},
    this.remainingSeconds = 0,
    this.result,
    this.nextUnlocked = false,
    this.unlockBlockedBy = LockBlockReason.none,
    this.errorMessage,
    this.isLoading = false,
    this.isProctoringPaused = false,
    this.pauseReason,
    this.proctoringWarnings = 0,
    this.showProctoringDialog = false,
  });

  final LessonModel lesson;
  final ExamPhase phase;
  final List<QuestionModel> questions;
  final int currentIndex;
  final String? currentSelection;
  final Map<String, String> selectedAnswers;
  final int remainingSeconds;
  final ExamResultModel? result;
  final bool nextUnlocked;
  final LockBlockReason unlockBlockedBy;
  final String? errorMessage;
  final bool isLoading;
  final bool isProctoringPaused;
  final ProctoringEvent? pauseReason;
  final int proctoringWarnings;
  final bool showProctoringDialog;

  QuestionModel? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length
          ? null
          : questions[currentIndex];

  int get totalQuestions => questions.length;

  bool get isLastQuestion => currentIndex >= totalQuestions - 1;

  bool get canSubmitCurrent =>
      currentSelection != null &&
      currentSelection!.isNotEmpty &&
      !isProctoringPaused;

  String get timerLabel {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  ExamState copyWith({
    ExamPhase? phase,
    List<QuestionModel>? questions,
    int? currentIndex,
    String? currentSelection,
    bool clearSelection = false,
    Map<String, String>? selectedAnswers,
    int? remainingSeconds,
    ExamResultModel? result,
    bool? nextUnlocked,
    LockBlockReason? unlockBlockedBy,
    String? errorMessage,
    bool clearError = false,
    bool? isLoading,
    bool? isProctoringPaused,
    ProctoringEvent? pauseReason,
    bool clearPauseReason = false,
    int? proctoringWarnings,
    bool? showProctoringDialog,
  }) {
    return ExamState(
      lesson: lesson,
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      currentSelection: clearSelection
          ? null
          : (currentSelection ?? this.currentSelection),
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      result: result ?? this.result,
      nextUnlocked: nextUnlocked ?? this.nextUnlocked,
      unlockBlockedBy: unlockBlockedBy ?? this.unlockBlockedBy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      isProctoringPaused: isProctoringPaused ?? this.isProctoringPaused,
      pauseReason:
          clearPauseReason ? null : (pauseReason ?? this.pauseReason),
      proctoringWarnings: proctoringWarnings ?? this.proctoringWarnings,
      showProctoringDialog: showProctoringDialog ?? this.showProctoringDialog,
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        phase,
        questions,
        currentIndex,
        currentSelection,
        selectedAnswers,
        remainingSeconds,
        result,
        nextUnlocked,
        unlockBlockedBy,
        errorMessage,
        isLoading,
        isProctoringPaused,
        pauseReason,
        proctoringWarnings,
        showProctoringDialog,
      ];
}
