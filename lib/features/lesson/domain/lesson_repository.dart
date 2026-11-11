import '../../../models/lesson_model.dart';
import '../../../models/study_plan_bundle.dart';

/// O‘quv rejasi va dars holati. Faqat saqlash va holat yangilash.
abstract class LessonRepository {
  bool get hasStudyPlan;

  Future<void> setStudyPlanReady(bool value);

  Future<void> saveStudyPlanBundle(StudyPlanBundle bundle);

  StudyPlanBundle? getStudyPlanBundle();

  Future<void> clearStudyPlan();

  LessonModel? getLessonById(String id);

  Future<void> updateLesson(LessonModel lesson);

  /// Keyingi `locked` darsni `available` qiladi. Ochilmasa `false`.
  Future<bool> unlockNextLesson(LessonModel current);

  Future<void> markExamWeekCompleted(int weekNumber);
}
