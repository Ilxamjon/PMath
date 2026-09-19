import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/grading_result.dart';
import '../../../../models/homework_model.dart';
import '../../../homework/data/homework_service.dart';
import '../../domain/ai_grading_service.dart';

enum GradingPhase { loading, result, error }

class GradingState extends Equatable {
  const GradingState({
    required this.homework,
    this.phase = GradingPhase.loading,
    this.result,
    this.nextUnlocked = false,
    this.errorMessage,
  });

  final HomeworkModel homework;
  final GradingPhase phase;
  final GradingResult? result;
  final bool nextUnlocked;
  final String? errorMessage;

  GradingState copyWith({
    HomeworkModel? homework,
    GradingPhase? phase,
    GradingResult? result,
    bool? nextUnlocked,
    String? errorMessage,
  }) {
    return GradingState(
      homework: homework ?? this.homework,
      phase: phase ?? this.phase,
      result: result ?? this.result,
      nextUnlocked: nextUnlocked ?? this.nextUnlocked,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [homework, phase, result, nextUnlocked, errorMessage];
}

class GradingCubit extends Cubit<GradingState> {
  GradingCubit({
    required HomeworkModel homework,
    required AiGradingService gradingService,
    required HomeworkService homeworkService,
  })  : _grader = gradingService,
        _homeworkService = homeworkService,
        super(GradingState(homework: homework));

  final AiGradingService _grader;
  final HomeworkService _homeworkService;

  Future<void> run() async {
    emit(state.copyWith(phase: GradingPhase.loading));
    try {
      final steps = state.homework.extractedSteps;
      if (steps.isEmpty) {
        emit(state.copyWith(
          phase: GradingPhase.error,
          errorMessage: 'Qadamlar topilmadi. Avval skanerlang.',
        ));
        return;
      }

      final result = await _grader.grade(
        homework: state.homework,
        studentSteps: steps,
      );

      final (updated, unlocked) = await _homeworkService.applyGrade(
        homework: state.homework,
        result: result,
      );

      emit(state.copyWith(
        phase: GradingPhase.result,
        homework: updated,
        result: result,
        nextUnlocked: unlocked,
      ));
    } catch (e) {
      emit(state.copyWith(
        phase: GradingPhase.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
