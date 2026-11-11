import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/core/utils/mastery_helper.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/models/study_plan_bundle.dart';
import 'package:pmath/models/study_plan_model.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<StorageService> _open({DateTime Function()? now}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return StorageService.open(
    prefs: prefs,
    executor: NativeDatabase.memory(),
    now: now,
  );
}

LessonModel _lesson({
  required String id,
  required int order,
  LessonStatus status = LessonStatus.locked,
  int durationMinutes = 20,
}) {
  return LessonModel(
    id: id,
    titleUz: 'Dars $id',
    orderIndex: order,
    topic: 'Arifmetika',
    weekNumber: 1,
    status: status,
    durationMinutes: durationMinutes,
  );
}

StudyPlanBundle _bundle(List<LessonModel> lessons) {
  return StudyPlanBundle(
    plan: StudyPlanModel(
      id: 'plan-1',
      userId: 'u1',
      createdAt: DateTime.utc(2026, 1, 1),
      weeks: const [],
    ),
    lessons: lessons,
  );
}

UserModel _userWithAccess(DateTime now) {
  return UserModel(
    id: 'u1',
    studentName: 'Ali',
    grade: StudentGrade.grade4,
    targetSchool: 'Prezident maktabi',
    parentPhone: '+998901234567',
    createdAt: now,
    coins: 10,
    xp: 10,
    level: 1,
    streakDays: 1,
    lastActiveDate: now,
    trialStartedAt: now,
    subscriptionExpiresAt: now.add(const Duration(days: 7)),
    serverNowAtFetch: now,
    deviceObservedAt: now,
  );
}

HomeworkModel _homework({
  required String id,
  required DateTime assignedAt,
  String lessonId = 'l1',
  String titleUz = 'Vazifa',
  HomeworkStatus status = HomeworkStatus.assigned,
}) {
  return HomeworkModel(
    id: id,
    lessonId: lessonId,
    titleUz: titleUz,
    assignedAt: assignedAt,
    status: status,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('applyPracticeResult', () {
    test('mastery 79% bo‘lsa ham dars completed, keyingi dars yopiq', () async {
      final now = DateTime.now();
      final storage = await _open();
      final current = _lesson(id: 'a', order: 1, status: LessonStatus.available);
      final next = _lesson(id: 'b', order: 2);
      await storage.saveUser(_userWithAccess(now));
      await storage.saveStudyPlanBundle(_bundle([next, current]));

      final attempt = await storage.applyPracticeResult(
        lesson: current,
        masteryPercent: 79,
        coinsEarned: 20,
      );

      final saved = storage.getLessonById('a');
      final savedNext = storage.getLessonById('b');
      expect(saved?.status, LessonStatus.completed);
      expect(saved?.masteryPercent, 79);
      expect(saved?.completedAt, isNotNull);
      expect(savedNext?.status, LessonStatus.locked);
      expect(attempt, UnlockAttempt.failedMastery);
      expect(storage.getUser()?.coins, 30);
      expect(storage.getUser()?.totalStudyMinutes, 20);
      expect(storage.getWeeklyXp(), 40);
    });

    test('80% va obuna keyingi darsni orderIndex bo‘yicha ochadi', () async {
      final now = DateTime.now();
      final storage = await _open();
      final current = _lesson(id: 'a', order: 1, status: LessonStatus.available);
      final next = _lesson(id: 'b', order: 2);
      await storage.saveUser(_userWithAccess(now));
      await storage.saveStudyPlanBundle(_bundle([next, current]));

      final attempt = await storage.applyPracticeResult(
        lesson: current,
        masteryPercent: 80,
        coinsEarned: 20,
      );

      expect(attempt, UnlockAttempt.success);
      expect(storage.getLessonById('a')?.status, LessonStatus.completed);
      expect(storage.getLessonById('b')?.status, LessonStatus.available);
    });

    test('obuna yo‘q bo‘lsa keyingi dars ochilmaydi', () async {
      final now = DateTime.now();
      final storage = await _open();
      final current = _lesson(id: 'a', order: 1, status: LessonStatus.available);
      final next = _lesson(id: 'b', order: 2);
      await storage.saveUser(
        UserModel(
          id: 'u1',
          studentName: 'Ali',
          grade: StudentGrade.grade4,
          targetSchool: 'Prezident maktabi',
          parentPhone: '+998901234567',
          createdAt: now,
          coins: 0,
          lastActiveDate: now,
        ),
      );
      await storage.saveStudyPlanBundle(_bundle([current, next]));

      final attempt = await storage.applyPracticeResult(
        lesson: current,
        masteryPercent: 95,
        coinsEarned: 0,
      );

      expect(attempt, UnlockAttempt.failedSubscription);
      expect(storage.getLessonById('b')?.status, LessonStatus.locked);
      expect(storage.getLessonById('a')?.status, LessonStatus.completed);
    });

    test('keyingi dars bo‘lmasa noNext', () async {
      final now = DateTime.now();
      final storage = await _open();
      final current = _lesson(id: 'a', order: 1, status: LessonStatus.available);
      await storage.saveUser(_userWithAccess(now));
      await storage.saveStudyPlanBundle(_bundle([current]));

      final attempt = await storage.applyPracticeResult(
        lesson: current,
        masteryPercent: 90,
        coinsEarned: 0,
      );

      expect(attempt, UnlockAttempt.noNext);
    });

    // TODO(retry): past mastery darsni qayta ochadigan oqim yo‘q.
    // Hozirgi xulq-atvor: completed qoladi, alohida Retry chaqiruvi mavjud emas.
    test('Retry oqimi yo‘q — past mastery completed qoladi', () async {
      final now = DateTime.now();
      final storage = await _open();
      final current = _lesson(id: 'a', order: 1, status: LessonStatus.inProgress);
      await storage.saveUser(_userWithAccess(now));
      await storage.saveStudyPlanBundle(_bundle([current]));

      await storage.applyPracticeResult(
        lesson: current,
        masteryPercent: 40,
        coinsEarned: 0,
      );

      final saved = storage.getLessonById('a');
      expect(saved?.status, LessonStatus.completed);
      expect(saved?.status, isNot(LessonStatus.available));
      expect(storage.getLessonById('a')?.masteryPercent, 40);
    });
  });

  group('haftalik XP', () {
    test('shu haftada qo‘shiladi', () async {
      final storage = await _open();
      await storage.addWeeklyXp(10);
      await storage.addWeeklyXp(5);
      expect(storage.getWeeklyXp(), 15);
    });

    test('yangi haftada eski XP hisoblanmaydi', () async {
      var clock = DateTime.utc(2026, 11, 11);
      final storage = await _open(now: () => clock);
      await storage.addWeeklyXp(10);
      expect(storage.getWeeklyXp(), 10);

      clock = DateTime.utc(2026, 11, 18);
      expect(storage.getWeeklyXp(), 0);
      await storage.addWeeklyXp(4);
      expect(storage.getWeeklyXp(), 4);
    });
  });

  group('uyga vazifa', () {
    test('yaratish, yangilash, o‘qish va o‘chirish', () async {
      final storage = await _open();
      final older = _homework(
        id: 'old',
        assignedAt: DateTime.utc(2026, 11, 1),
        titleUz: 'Eski',
      );
      final newer = _homework(
        id: 'new',
        assignedAt: DateTime.utc(2026, 11, 10),
        lessonId: 'l2',
        titleUz: 'Yangi',
        status: HomeworkStatus.needsRevision,
      );
      final graded = _homework(
        id: 'done',
        assignedAt: DateTime.utc(2026, 11, 11),
        lessonId: 'l2',
        status: HomeworkStatus.graded,
      );

      await storage.upsertHomework(older);
      await storage.upsertHomework(newer);
      await storage.upsertHomework(graded);

      expect(
        storage.getHomeworkList().map((h) => h.id).toList(),
        ['done', 'new', 'old'],
      );

      await storage.upsertHomework(newer.copyWith(titleUz: 'Tahrir'));
      expect(storage.getHomeworkById('new')?.titleUz, 'Tahrir');
      expect(storage.getHomeworkList().length, 3);

      expect(storage.getHomeworkForLesson('l2')?.id, 'new');
      expect(
        storage.getHomeworkListForLesson('l2').map((h) => h.id).toList(),
        ['done', 'new'],
      );

      await storage.deleteHomework('old');
      expect(storage.getHomeworkById('old'), isNull);
      expect(storage.getHomeworkList().map((h) => h.id), ['done', 'new']);
    });
  });
}
