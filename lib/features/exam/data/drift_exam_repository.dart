import '../../../core/storage/local_snapshot.dart';
import '../../../models/exam_result_model.dart';
import '../domain/exam_repository.dart';

class DriftExamRepository implements ExamRepository {
  DriftExamRepository(this._store);

  final LocalSnapshot _store;

  @override
  List<ExamResultModel> getExamResults() {
    return [..._store.exams]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  Future<void> saveExamResult(ExamResultModel result) async {
    final list = List<ExamResultModel>.from(getExamResults());
    list.insert(0, result);
    await _store.saveExams(list);
  }

  @override
  ExamResultModel? getLatestExamResult() {
    final list = getExamResults();
    return list.isEmpty ? null : list.first;
  }

  @override
  ExamResultModel? getExamResultForLesson(String lessonId) {
    for (final item in getExamResults()) {
      if (item.lessonId == lessonId) return item;
    }
    return null;
  }
}
