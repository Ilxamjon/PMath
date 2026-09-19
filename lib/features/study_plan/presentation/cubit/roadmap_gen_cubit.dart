import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../models/diagnostic_result_model.dart';
import '../../data/study_plan_repository.dart';
import 'roadmap_gen_state.dart';

/// Diagnostika → AI roadmap generatsiya oqimi.
class RoadmapGenCubit extends Cubit<RoadmapGenState> {
  RoadmapGenCubit({
    required StudyPlanRepository repository,
    required this.userId,
  })  : _repo = repository,
        super(const RoadmapGenState());

  final StudyPlanRepository _repo;
  final String userId;

  Future<void> generate(DiagnosticResultModel diagnostic) async {
    emit(const RoadmapGenState(
      phase: RoadmapGenPhase.generating,
      progressStep: 0,
    ));

    // Bosqichma-bosqich progress UI.
    await _tick(1);
    await _tick(2);
    await _tick(3);

    try {
      final bundle = await _repo.generateAndSave(
        userId: userId,
        diagnostic: diagnostic,
      );
      if (isClosed) return;
      emit(RoadmapGenState(
        phase: RoadmapGenPhase.ready,
        progressStep: 4,
        bundle: bundle,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        phase: RoadmapGenPhase.error,
        errorMessage: AppStrings.somethingWrong,
      ));
    }
  }

  Future<void> _tick(int step) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (isClosed) return;
    emit(state.copyWith(progressStep: step));
  }
}
