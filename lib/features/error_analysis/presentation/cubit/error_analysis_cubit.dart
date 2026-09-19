import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/homework_model.dart';
import '../../../../services/tts_service.dart';
import '../../domain/error_analysis_coach.dart';

/// Bitta xato ichidagi interaktiv bosqichlar.
enum ErrorStepPhase {
  /// Xato + sodda tushuntirish.
  explain,

  /// Sokratik savollar.
  socratic,

  /// Yumshoq ishora (to‘liq javob emas).
  softHint,

  /// Ixtiyoriy: to‘liq to‘g‘ri yo‘l.
  fullHint,
}

class ErrorAnalysisState extends Equatable {
  const ErrorAnalysisState({
    required this.homework,
    required this.items,
    this.index = 0,
    this.phase = ErrorStepPhase.explain,
    this.isSpeaking = false,
    this.finished = false,
  });

  final HomeworkModel homework;
  final List<AnalyzedError> items;
  final int index;
  final ErrorStepPhase phase;
  final bool isSpeaking;
  final bool finished;

  AnalyzedError? get current =>
      items.isEmpty || index >= items.length ? null : items[index];

  int get total => items.length;

  bool get hasNextError => index < items.length - 1;

  ErrorAnalysisState copyWith({
    int? index,
    ErrorStepPhase? phase,
    bool? isSpeaking,
    bool? finished,
  }) {
    return ErrorAnalysisState(
      homework: homework,
      items: items,
      index: index ?? this.index,
      phase: phase ?? this.phase,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      finished: finished ?? this.finished,
    );
  }

  @override
  List<Object?> get props =>
      [homework, items, index, phase, isSpeaking, finished];
}

class ErrorAnalysisCubit extends Cubit<ErrorAnalysisState> {
  ErrorAnalysisCubit({
    required HomeworkModel homework,
    required TtsService tts,
    ErrorAnalysisCoach? coach,
  })  : _tts = tts,
        super(
          ErrorAnalysisState(
            homework: homework,
            items: (coach ?? const ErrorAnalysisCoach()).buildFor(homework),
          ),
        );

  final TtsService _tts;

  Future<void> start() async {
    if (state.items.isEmpty) {
      emit(state.copyWith(finished: true));
      return;
    }
    await speakExplain();
  }

  Future<void> speakExplain() async {
    final cur = state.current;
    if (cur == null) return;
    emit(state.copyWith(isSpeaking: true));
    await _tts.speak(cur.simpleExplainUz);
    if (!isClosed) emit(state.copyWith(isSpeaking: false));
  }

  Future<void> stopSpeak() => _tts.stop();

  void continuePhase() {
    if (state.finished) return;
    final cur = state.current;
    if (cur == null) {
      emit(state.copyWith(finished: true));
      return;
    }

    final next = switch (state.phase) {
      ErrorStepPhase.explain => ErrorStepPhase.socratic,
      ErrorStepPhase.socratic => ErrorStepPhase.softHint,
      ErrorStepPhase.softHint =>
        (cur.fullHintUz != null && cur.fullHintUz!.isNotEmpty)
            ? ErrorStepPhase.fullHint
            : null,
      ErrorStepPhase.fullHint => null,
    };

    if (next != null) {
      emit(state.copyWith(phase: next));
    } else {
      _advanceError();
    }
  }

  void _advanceError() {
    if (state.hasNextError) {
      emit(state.copyWith(
        index: state.index + 1,
        phase: ErrorStepPhase.explain,
      ));
      speakExplain();
    } else {
      emit(state.copyWith(finished: true));
    }
  }

  @override
  Future<void> close() async {
    await _tts.stop();
    return super.close();
  }
}
