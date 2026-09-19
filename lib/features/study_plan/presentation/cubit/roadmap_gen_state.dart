import 'package:equatable/equatable.dart';

import '../../../../models/study_plan_bundle.dart';

enum RoadmapGenPhase { idle, generating, ready, error }

class RoadmapGenState extends Equatable {
  const RoadmapGenState({
    this.phase = RoadmapGenPhase.idle,
    this.progressStep = 0,
    this.bundle,
    this.errorMessage,
  });

  final RoadmapGenPhase phase;

  /// 0..3 — animatsiya qadamlari.
  final int progressStep;
  final StudyPlanBundle? bundle;
  final String? errorMessage;

  RoadmapGenState copyWith({
    RoadmapGenPhase? phase,
    int? progressStep,
    StudyPlanBundle? bundle,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoadmapGenState(
      phase: phase ?? this.phase,
      progressStep: progressStep ?? this.progressStep,
      bundle: bundle ?? this.bundle,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [phase, progressStep, bundle, errorMessage];
}
