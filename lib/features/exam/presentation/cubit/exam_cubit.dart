import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/exam_result_model.dart';
import '../../../../models/lesson_model.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../data/exam_question_bank.dart';
import '../../domain/exam_scorer.dart';
import 'exam_state.dart';

/// Mini-imtihon: intro → timerli quiz (+ proctoring pauza) → natija.
class ExamCubit extends Cubit<ExamState> {
  ExamCubit({
    required LessonModel lesson,
    required StorageService storage,
    required String userId,
    ProctoringGuard? proctoring,
    ParentAlertService? parentAlerts,
    Uuid? uuid,
  })  : _storage = storage,
        _userId = userId,
        _proctoring = proctoring,
        _alerts = parentAlerts,
        _uuid = uuid ?? const Uuid(),
        super(ExamState(lesson: lesson)) {
    _proctoring?.addListener(_onProctoringEvent);
  }

  final StorageService _storage;
  final String _userId;
  final ProctoringGuard? _proctoring;
  final ParentAlertService? _alerts;
  final Uuid _uuid;

  Timer? _ticker;
  DateTime? _startedAt;
  var _dialogShown = false;

  void loadIntro() {
    final questions = ExamQuestionBank.forWeek(state.lesson.weekNumber);
    emit(state.copyWith(
      phase: ExamPhase.intro,
      questions: questions,
      remainingSeconds: AppConstants.examDurationMinutes * 60,
      clearError: true,
    ));
  }

  void startQuiz() {
    _startedAt = DateTime.now();
    _proctoring?.startSession(lessonId: state.lesson.id);
    emit(state.copyWith(
      phase: ExamPhase.quiz,
      currentIndex: 0,
      selectedAnswers: {},
      clearSelection: true,
      remainingSeconds: AppConstants.examDurationMinutes * 60,
      isProctoringPaused: false,
      clearPauseReason: true,
      showProctoringDialog: false,
      clearError: true,
    ));
    _startTimer();
  }

  void selectAnswer(String answer) {
    if (state.isProctoringPaused) return;
    emit(state.copyWith(currentSelection: answer, clearError: true));
  }

  void submitCurrentAndNext() {
    if (state.isProctoringPaused) return;
    if (!state.canSubmitCurrent || state.currentQuestion == null) {
      emit(state.copyWith(errorMessage: AppStrings.examSelectAnswer));
      return;
    }

    final q = state.currentQuestion!;
    final updated = Map<String, String>.from(state.selectedAnswers)
      ..[q.id] = state.currentSelection!;

    if (state.isLastQuestion) {
      emit(state.copyWith(selectedAnswers: updated));
      _finish();
      return;
    }

    emit(state.copyWith(
      selectedAnswers: updated,
      currentIndex: state.currentIndex + 1,
      clearSelection: true,
      clearError: true,
    ));
  }

  void _onProctoringEvent(ProctoringEvent event) {
    if (isClosed) return;
    if (state.phase != ExamPhase.quiz) return;

    if (event.isViolation) {
      _ticker?.cancel();
      _ticker = null;
      emit(state.copyWith(
        isProctoringPaused: true,
        pauseReason: event,
        proctoringWarnings: _proctoring?.sessionWarningCount ??
            state.proctoringWarnings + 1,
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
      if (state.phase == ExamPhase.quiz) _startTimer();
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

  /// Modal yopilgandan keyin.
  void resumeAfterProctoring() {
    _proctoring?.resumeAfterWarning();
    // Listener `resumed` eventini ham qayta ishlaydi; agar stub kechiksa:
    if (state.isProctoringPaused) {
      _dialogShown = false;
      emit(state.copyWith(
        isProctoringPaused: false,
        clearPauseReason: true,
        showProctoringDialog: false,
      ));
      _startTimer();
    }
  }

  void clearProctoringDialogFlag() {
    emit(state.copyWith(showProctoringDialog: false));
  }

  void simulateProctoringViolation() {
    _proctoring?.simulate(ProctoringEvent.noFace);
  }

  void _startTimer() {
    _ticker?.cancel();
    if (state.isProctoringPaused) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      if (state.isProctoringPaused) return;
      final left = state.remainingSeconds - 1;
      if (left <= 0) {
        emit(state.copyWith(remainingSeconds: 0));
        _finish(timeUp: true);
        return;
      }
      emit(state.copyWith(remainingSeconds: left));
    });
  }

  void _finish({bool timeUp = false}) {
    _ticker?.cancel();
    _ticker = null;
    _proctoring?.endSession();

    final elapsed = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inSeconds;

    final result = ExamScorer.build(
      id: _uuid.v4(),
      userId: _userId,
      lesson: state.lesson,
      questions: state.questions,
      selectedAnswers: state.selectedAnswers,
      durationSeconds: elapsed,
      timeUp: timeUp,
    );

    emit(state.copyWith(isLoading: true, isProctoringPaused: false));
    unawaited(_persist(result, timeUp: timeUp));
  }

  Future<void> _persist(
    ExamResultModel result, {
    required bool timeUp,
  }) async {
    try {
      await _storage.saveExamResult(result);

      final attempt = await _storage.applyPracticeResult(
        lesson: state.lesson,
        masteryPercent: result.overallPercent,
        coinsEarned: result.coinsEarned,
      );

      await _storage.markExamWeekCompleted(state.lesson.weekNumber);

      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        phase: ExamPhase.results,
        result: result,
        nextUnlocked: attempt.unlocked,
        unlockBlockedBy: attempt.blockedBy,
        errorMessage: timeUp ? AppStrings.examTimeUp : null,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        phase: ExamPhase.results,
        result: result,
        errorMessage: AppStrings.somethingWrong,
      ));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _proctoring?.removeListener(_onProctoringEvent);
    _proctoring?.endSession();
    return super.close();
  }
}
