import '../../../core/storage/local_snapshot.dart';
import '../../../models/lesson_model.dart';
import '../../../models/study_plan_bundle.dart';
import '../../../models/study_plan_model.dart';
import '../domain/lesson_repository.dart';

class DriftLessonRepository implements LessonRepository {
  DriftLessonRepository(this._store);

  final LocalSnapshot _store;

  @override
  bool get hasStudyPlan => _store.studyPlanReady;

  @override
  Future<void> setStudyPlanReady(bool value) => _store.setStudyPlanReady(value);

  @override
  Future<void> saveStudyPlanBundle(StudyPlanBundle bundle) =>
      _store.saveStudyPlan(bundle);

  @override
  StudyPlanBundle? getStudyPlanBundle() => _store.studyPlan;

  @override
  Future<void> clearStudyPlan() => _store.clearStudyPlan();

  @override
  LessonModel? getLessonById(String id) {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return null;
    for (final lesson in bundle.lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  @override
  Future<void> updateLesson(LessonModel lesson) async {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return;

    final updatedLessons = bundle.lessons.map((item) {
      return item.id == lesson.id ? lesson : item;
    }).toList();

    await saveStudyPlanBundle(
      StudyPlanBundle(plan: bundle.plan, lessons: updatedLessons),
    );
  }

  @override
  Future<bool> unlockNextLesson(LessonModel current) async {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return false;

    final sorted = [...bundle.lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final idx = sorted.indexWhere((lesson) => lesson.id == current.id);
    if (idx < 0 || idx >= sorted.length - 1) return false;

    final next = sorted[idx + 1];
    if (next.status != LessonStatus.locked) return false;

    final unlockedNext = next.copyWith(status: LessonStatus.available);
    final updatedLessons = bundle.lessons.map((lesson) {
      if (lesson.id == current.id) return current;
      if (lesson.id == next.id) return unlockedNext;
      return lesson;
    }).toList();

    await saveStudyPlanBundle(
      StudyPlanBundle(plan: bundle.plan, lessons: updatedLessons),
    );
    return true;
  }

  @override
  Future<void> markExamWeekCompleted(int weekNumber) async {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return;

    final weeks = bundle.plan.weeks.map((week) {
      if (week.weekNumber == weekNumber && week.isExamWeek) {
        return WeeklyPlan(
          weekNumber: week.weekNumber,
          titleUz: week.titleUz,
          focusTopics: week.focusTopics,
          lessonIds: week.lessonIds,
          isExamWeek: week.isExamWeek,
          completed: true,
        );
      }
      return week;
    }).toList();

    await saveStudyPlanBundle(
      StudyPlanBundle(
        plan: bundle.plan.copyWith(weeks: weeks),
        lessons: bundle.lessons,
      ),
    );
  }
}
