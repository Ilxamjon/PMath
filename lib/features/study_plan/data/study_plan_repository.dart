import '../../../models/diagnostic_result_model.dart';
import '../../../models/study_plan_bundle.dart';
import '../../../services/storage_service.dart';
import '../domain/ai_study_plan_generator.dart';

abstract class StudyPlanRepository {
  Future<StudyPlanBundle> generateAndSave({
    required String userId,
    required DiagnosticResultModel diagnostic,
  });

  StudyPlanBundle? getBundle();
  bool get hasPlan;
  Future<void> clear();
}

class LocalStudyPlanRepository implements StudyPlanRepository {
  LocalStudyPlanRepository({
    required this._storage,
    required this._generator,
  });

  final StorageService _storage;
  final StudyPlanGenerator _generator;

  @override
  bool get hasPlan => _storage.hasStudyPlan;

  @override
  StudyPlanBundle? getBundle() => _storage.getStudyPlanBundle();

  @override
  Future<StudyPlanBundle> generateAndSave({
    required String userId,
    required DiagnosticResultModel diagnostic,
  }) async {
    final bundle = await _generator.generate(
      userId: userId,
      diagnostic: diagnostic,
    );
    await _storage.saveStudyPlanBundle(bundle);
    await _storage.setStudyPlanReady(true);
    return bundle;
  }

  @override
  Future<void> clear() => _storage.clearStudyPlan();
}
