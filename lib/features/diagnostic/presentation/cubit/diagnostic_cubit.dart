import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/diagnostic_result_model.dart';
import '../../data/diagnostic_repository.dart';
import '../../domain/diagnostic_scorer.dart';
import 'diagnostic_state.dart';

/// Diagnostik test: intro → quiz (timer) → results.
class DiagnosticCubit extends Cubit<DiagnosticState> {
  DiagnosticCubit({
    required DiagnosticRepository repository,
    required this.userId,
    Uuid? uuid,
  })  : _repo = repository,
        _uuid = uuid ?? const Uuid(),
        super(const DiagnosticState());

  final DiagnosticRepository _repo;
  final String userId;
  final Uuid _uuid;

  Timer? _ticker;
  DateTime? _startedAt;

  void loadIntro() {
    final questions = _repo.getQuestions();
    emit(state.copyWith(
      phase: DiagnosticPhase.intro,
      questions: questions,
      remainingSeconds:
          AppConstants.diagnosticDurationMinutes * 60,
      clearError: true,
    ));
  }

  void startQuiz() {
    _startedAt = DateTime.now();
    emit(state.copyWith(
      phase: DiagnosticPhase.quiz,
      currentIndex: 0,
      selectedAnswers: {},
      clearSelection: true,
      remainingSeconds:
          AppConstants.diagnosticDurationMinutes * 60,
      clearError: true,
    ));
    _startTimer();
  }

  void selectAnswer(String answer) {
    emit(state.copyWith(currentSelection: answer, clearError: true));
  }

  void submitCurrentAndNext() {
    if (!state.canSubmitCurrent || state.currentQuestion == null) {
      emit(state.copyWith(errorMessage: AppStrings.diagnosticSelectAnswer));
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

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
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

    final elapsed = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inSeconds;

    final result = DiagnosticScorer.buildResult(
      id: _uuid.v4(),
      userId: userId,
      questions: state.questions,
      selectedAnswers: state.selectedAnswers,
      durationSeconds: elapsed,
    );

    emit(state.copyWith(isLoading: true));

    // Fire-and-forget persist, then show results.
    _persist(result, timeUp: timeUp);
  }

  Future<void> _persist(
    DiagnosticResultModel result, {
    required bool timeUp,
  }) async {
    try {
      await _repo.saveResult(result);
      await _repo.markCompleted();
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        phase: DiagnosticPhase.results,
        result: result,
        errorMessage: timeUp ? AppStrings.diagnosticTimeUp : null,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        phase: DiagnosticPhase.results,
        result: result,
        errorMessage: AppStrings.somethingWrong,
      ));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
