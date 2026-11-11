import '../../../models/exam_result_model.dart';

/// Mini-imtihon natijalari.
abstract class ExamRepository {
  List<ExamResultModel> getExamResults();

  Future<void> saveExamResult(ExamResultModel result);

  ExamResultModel? getLatestExamResult();

  ExamResultModel? getExamResultForLesson(String lessonId);
}
