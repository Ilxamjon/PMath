import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/lesson_model.dart';
import '../../../../core/navigation/app_shell_nav.dart';
import '../../../../services/gamification_service.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../homework/data/homework_service.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../domain/practice_question_factory.dart';
import 'practice_state.dart';

/// Darsdan keyingi gamified mashq: 15 savol + proctoring + 15 uyga vazifa.
class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit({
    required LessonModel lesson,
    required StorageService storage,
    required HomeworkService homeworkService,
    required ProctoringGuard proctoring,
    ParentAlertService? parentAlerts,
    GamificationService? gamification,
  })  : _storage = storage,
        _homework = homeworkService,
        _proctoring = proctoring,
        _alerts = parentAlerts,
        _game = gamification ?? GamificationService(),
        super(PracticeState(
          lesson: lesson,
          questions: PracticeQuestionFactory.forLesson(lesson),
        )) {
    _proctoring.addListener(_onProctoring);
  }

  final StorageService _storage;
  final HomeworkService _homework;
  final ProctoringGuard _proctoring;
  final ParentAlertService? _alerts;
  final GamificationService _game;
  var _dialogShown = false;

  static const int _coinsPerCorrect = 5;
  static const int _comboBonus = 3;

  Future<void> start() async {
    _proctoring.startSession(lessonId: 'practice_${state.lesson.id}');
    emit(state.copyWith(
      proctoringActive: true,
      isProctoringPaused: false,
    ));
  }

  void _onProctoring(ProctoringEvent event) {
    if (isClosed) return;
    if (state.phase == PracticePhase.results) return;

    if (event.isViolation) {
      emit(state.copyWith(
        isProctoringPaused: true,
        pauseReason: event,
        proctoringWarnings: _proctoring.sessionWarningCount,
        showProctoringDialog: !_dialogShown,
      ));
      _dialogShown = true;
      unawaited(_recordWarning(event));
    } else if (event == ProctoringEvent.resumed) {
      _dialogShown = false;
      emit(state.copyWith(
        isProctoringPaused: false,
        clearPauseReason: true,
        showProctoringDialog: false,
      ));
    }
  }

  Future<void> _recordWarning(ProctoringEvent event) async {
    final total = await _storage.recordCheatingWarning();
    final user = _storage.getUser();
    if (user != null && _alerts != null) {
      await _alerts.cheatingWarning(
        user: user,
        reasonUz: event.titleUz,
        totalWarnings: total,
      );
    }
  }

  void resumeAfterProctoring() {
    _proctoring.resumeAfterWarning();
    _dialogShown = false;
    emit(state.copyWith(
      isProctoringPaused: false,
      clearPauseReason: true,
      showProctoringDialog: false,
    ));
  }

  void clearProctoringDialogFlag() {
    emit(state.copyWith(showProctoringDialog: false));
  }

  void selectAnswer(String answer) {
    if (state.phase != PracticePhase.quiz || state.isProctoringPaused) return;
    emit(state.copyWith(selectedAnswer: answer));
  }

  void submitAnswer() {
    if (state.phase != PracticePhase.quiz || state.isProctoringPaused) return;
    final q = state.currentQuestion;
    final selected = state.selectedAnswer;
    if (q == null || selected == null || selected.isEmpty) return;

    final correct = q.checkAnswer(selected);
    final newCombo = correct ? state.combo + 1 : 0;
    final maxCombo =
        newCombo > state.maxCombo ? newCombo : state.maxCombo;

    var coins = state.coinsEarned;
    if (correct) {
      coins += _coinsPerCorrect;
      if (newCombo >= 3) coins += _comboBonus;
    }

    emit(state.copyWith(
      phase: PracticePhase.feedback,
      lastAnswerCorrect: correct,
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      combo: newCombo,
      maxCombo: maxCombo,
      coinsEarned: coins,
    ));
  }

  Future<void> continueAfterFeedback() async {
    if (state.phase != PracticePhase.feedback || state.isProctoringPaused) {
      return;
    }

    if (state.isLast) {
      await _finish();
      return;
    }

    emit(state.copyWith(
      phase: PracticePhase.quiz,
      currentIndex: state.currentIndex + 1,
      clearSelection: true,
      clearFeedback: true,
    ));
  }

  Future<void> _finish() async {
    _proctoring.endSession();
    final mastery = state.total == 0
        ? 0.0
        : (state.correctCount / state.total) * 100;

    final blended = (40 + mastery * 0.6).clamp(0.0, 100.0);

    final bonus = _game.rewardForMastery(blended);
    final totalCoins = state.coinsEarned + bonus;

    final attempt = await _storage.applyPracticeResult(
      lesson: state.lesson,
      masteryPercent: blended,
      coinsEarned: totalCoins,
    );

    final homeworkSet = await _homework.assignForLesson(state.lesson);

    emit(state.copyWith(
      phase: PracticePhase.results,
      masteryPercent: blended,
      coinsEarned: totalCoins,
      nextUnlocked: attempt.unlocked,
      unlockBlockedBy: attempt.blockedBy,
      assignedHomework: homeworkSet.isNotEmpty ? homeworkSet.first : null,
      assignedHomeworkList: homeworkSet,
      proctoringActive: false,
      isProctoringPaused: false,
      lesson: state.lesson.copyWith(
        status: LessonStatus.completed,
        masteryPercent: blended,
        completedAt: DateTime.now(),
      ),
    ));
  }

  Future<void> retry() async {
    _proctoring.endSession();
    emit(PracticeState(
      lesson: state.lesson,
      questions: PracticeQuestionFactory.forLesson(state.lesson),
    ));
    await start();
  }

  Future<void> openScannerTab() async {
    await _storage.setPendingShellTab(1);
    AppShellNav.openScanner();
  }

  @override
  Future<void> close() async {
    _proctoring.removeListener(_onProctoring);
    if (_proctoring.isActive) _proctoring.endSession();
    return super.close();
  }
}
