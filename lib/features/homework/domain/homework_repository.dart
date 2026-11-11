import '../../../models/homework_model.dart';

/// Uyga vazifa ro‘yxati.
abstract class HomeworkRepository {
  List<HomeworkModel> getHomeworkList();

  Future<void> saveHomeworkList(List<HomeworkModel> items);

  Future<void> upsertHomework(HomeworkModel homework);

  HomeworkModel? getHomeworkById(String id);

  HomeworkModel? getHomeworkForLesson(String lessonId);

  List<HomeworkModel> getHomeworkListForLesson(String lessonId);

  Future<void> deleteHomework(String id);

  List<HomeworkModel> get pendingHomework;

  List<HomeworkModel> get overdueHomework;
}
