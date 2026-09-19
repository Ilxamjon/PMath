import 'package:equatable/equatable.dart';

import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/homework_model.dart';
import '../../../../models/lesson_model.dart';
import '../../../../models/question_model.dart';
import '../../../proctoring/domain/proctoring_guard.dart';

enum PracticePhase { quiz, feedback, results }

class PracticeState extends Equatable {
  const PracticeState({
    required this.lesson,
    required this.questions,
    this.phase = PracticePhase.quiz,
    this.currentIndex = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.coinsEarned = 0,
    this.lastAnswerCorrect,
    this.masteryPercent = 0,
    this.nextUnlocked = false,
    this.unlockBlockedBy = LockBlockReason.none,
    this.assignedHomework,
    this.assignedHomeworkList = const [],
    this.proctoringActive = false,
    this.isProctoringPaused = false,
    this.pauseReason,
    this.proctoringWarnings = 0,
    this.showProctoringDialog = false,
  });

  final LessonModel lesson;
  final List<QuestionModel> questions;
  final PracticePhase phase;
  final int currentIndex;
  final String? selectedAnswer;
  final int correctCount;
  final int combo;
  final int maxCombo;
  final int coinsEarned;
  final bool? lastAnswerCorrect;
  final double masteryPercent;
  final bool nextUnlocked;
  final LockBlockReason unlockBlockedBy;
  final HomeworkModel? assignedHomework;
  final List<HomeworkModel> assignedHomeworkList;
  final bool proctoringActive;
  final bool isProctoringPaused;
  final ProctoringEvent? pauseReason;
  final int proctoringWarnings;
  final bool showProctoringDialog;

  QuestionModel? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length
          ? null
          : questions[currentIndex];

  int get total => questions.length;

  bool get isLast => currentIndex >= total - 1;

  double get progress => total == 0 ? 0 : (currentIndex + 1) / total;

  String get difficultyBadge {
    final q = currentQuestion;
    if (q == null) return '';
    return q.difficulty.labelUz;
  }

  PracticeState copyWith({
    LessonModel? lesson,
    List<QuestionModel>? questions,
    PracticePhase? phase,
    int? currentIndex,
    String? selectedAnswer,
    bool clearSelection = false,
    int? correctCount,
    int? combo,
    int? maxCombo,
    int? coinsEarned,
    bool? lastAnswerCorrect,
    bool clearFeedback = false,
    double? masteryPercent,
    bool? nextUnlocked,
    LockBlockReason? unlockBlockedBy,
    HomeworkModel? assignedHomework,
    List<HomeworkModel>? assignedHomeworkList,
    bool? proctoringActive,
    bool? isProctoringPaused,
    ProctoringEvent? pauseReason,
    bool clearPauseReason = false,
    int? proctoringWarnings,
    bool? showProctoringDialog,
  }) {
    return PracticeState(
      lesson: lesson ?? this.lesson,
      questions: questions ?? this.questions,
      phase: phase ?? this.phase,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer:
          clearSelection ? null : (selectedAnswer ?? this.selectedAnswer),
      correctCount: correctCount ?? this.correctCount,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      lastAnswerCorrect: clearFeedback
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      masteryPercent: masteryPercent ?? this.masteryPercent,
      nextUnlocked: nextUnlocked ?? this.nextUnlocked,
      unlockBlockedBy: unlockBlockedBy ?? this.unlockBlockedBy,
      assignedHomework: assignedHomework ?? this.assignedHomework,
      assignedHomeworkList:
          assignedHomeworkList ?? this.assignedHomeworkList,
      proctoringActive: proctoringActive ?? this.proctoringActive,
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
        questions,
        phase,
        currentIndex,
        selectedAnswer,
        correctCount,
        combo,
        maxCombo,
        coinsEarned,
        lastAnswerCorrect,
        masteryPercent,
        nextUnlocked,
        unlockBlockedBy,
        assignedHomework,
        assignedHomeworkList,
        proctoringActive,
        isProctoringPaused,
        pauseReason,
        proctoringWarnings,
        showProctoringDialog,
      ];
}
