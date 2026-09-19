import '../../../core/constants/app_constants.dart';
import '../../../models/diagnostic_result_model.dart';
import '../../../models/question_model.dart';
import '../../../services/storage_service.dart';
import 'diagnostic_question_bank.dart';

/// Diagnostik test ma’lumotlari: savollar + natijani saqlash.
abstract class DiagnosticRepository {
  List<QuestionModel> getQuestions();
  Future<void> saveResult(DiagnosticResultModel result);
  DiagnosticResultModel? getResult();
  bool get isCompleted;
  Future<void> markCompleted();
}

class LocalDiagnosticRepository implements DiagnosticRepository {
  LocalDiagnosticRepository(this._storage);

  final StorageService _storage;

  @override
  List<QuestionModel> getQuestions() {
    final all = DiagnosticQuestionBank.all;
    assert(all.length >= AppConstants.diagnosticQuestionCount);
    return all.take(AppConstants.diagnosticQuestionCount).toList();
  }

  @override
  Future<void> saveResult(DiagnosticResultModel result) =>
      _storage.saveDiagnosticResult(result);

  @override
  DiagnosticResultModel? getResult() => _storage.getDiagnosticResult();

  @override
  bool get isCompleted => _storage.isDiagnosticDone;

  @override
  Future<void> markCompleted() => _storage.setDiagnosticDone(true);
}
