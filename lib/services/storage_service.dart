import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../core/storage/local_snapshot.dart';
import '../core/storage/pmath_database.dart';
import '../core/storage/prefs_drift_migrator.dart';
import '../core/utils/mastery_helper.dart';
import '../features/exam/data/drift_exam_repository.dart';
import '../features/exam/domain/exam_repository.dart';
import '../features/gamification/data/drift_gamification_repository.dart';
import '../features/gamification/domain/gamification_repository.dart';
import '../features/gamification/domain/gamification_reward.dart';
import '../features/homework/data/drift_homework_repository.dart';
import '../features/homework/domain/homework_repository.dart';
import '../features/lesson/data/drift_lesson_repository.dart';
import '../features/lesson/domain/apply_practice_result.dart';
import '../features/lesson/domain/lesson_repository.dart';
import '../features/parent_dashboard/data/drift_parent_alert_repository.dart';
import '../features/parent_dashboard/domain/parent_alert_repository.dart';
import '../features/user/data/drift_user_repository.dart';
import '../features/user/domain/user_repository.dart';
import '../models/diagnostic_result_model.dart';
import '../models/exam_result_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/parent_alert_log.dart';
import '../models/study_plan_bundle.dart';
import '../models/user_model.dart';

/// Lokal saqlash. Disk — Drift (SQLite). Domen hisobi repository va use-case da.
class StorageService {
  StorageService._({
    required LocalSnapshot snapshot,
    required UserRepository users,
    required LessonRepository lessons,
    required HomeworkRepository homework,
    required ExamRepository exams,
    required GamificationRepository gamification,
    required ParentAlertRepository alerts,
    required ApplyPracticeResult applyPracticeResult,
  })  : _snapshot = snapshot,
        _users = users,
        _lessons = lessons,
        _homework = homework,
        _exams = exams,
        _gamification = gamification,
        _alerts = alerts,
        _apply = applyPracticeResult;

  final LocalSnapshot _snapshot;
  final UserRepository _users;
  final LessonRepository _lessons;
  final HomeworkRepository _homework;
  final ExamRepository _exams;
  final GamificationRepository _gamification;
  final ParentAlertRepository _alerts;
  final ApplyPracticeResult _apply;

  static Future<StorageService> init({DateTime Function()? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final executor = _runningTests
        ? NativeDatabase.memory()
        : await _productionExecutor();
    return open(prefs: prefs, executor: executor, now: now);
  }

  /// Test va migratsiya uchun. `executor` chaqiruvchi yopadi, yoki [close].
  static Future<StorageService> open({
    required SharedPreferences prefs,
    required QueryExecutor executor,
    DateTime Function()? now,
  }) async {
    final clock = now ?? DateTime.now;
    if (_runningTests) {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    }
    final db = PmathDatabase(executor);
    try {
      await PrefsDriftMigrator(prefs: prefs, db: db).migrate();
      final snapshot = LocalSnapshot(db, now: clock);
      await snapshot.load();
      final users = DriftUserRepository(snapshot);
      final lessons = DriftLessonRepository(snapshot);
      final homework = DriftHomeworkRepository(snapshot);
      final exams = DriftExamRepository(snapshot);
      final gamification = DriftGamificationRepository(snapshot, users);
      final alerts = DriftParentAlertRepository(snapshot);
      return StorageService._(
        snapshot: snapshot,
        users: users,
        lessons: lessons,
        homework: homework,
        exams: exams,
        gamification: gamification,
        alerts: alerts,
        applyPracticeResult: ApplyPracticeResult(
          lessons: lessons,
          users: users,
          gamification: gamification,
          now: clock,
        ),
      );
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  static bool get _runningTests =>
      Platform.environment.containsKey('FLUTTER_TEST');

  static Future<QueryExecutor> _productionExecutor() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'pmath.sqlite'));
    return NativeDatabase(file);
  }

  Future<void> close() => _snapshot.close();

  Future<void> saveUser(UserModel user) => _users.saveUser(user);

  Future<int> recordCheatingWarning() => _users.recordCheatingWarning();

  UserModel? getUser() => _users.getUser();

  Future<void> clearUser() => _users.clearUser();

  bool get isOnboardingDone => _users.isOnboardingDone;

  Future<void> setOnboardingDone(bool value) => _users.setOnboardingDone(value);

  Future<void> completeOnboarding(UserModel user) =>
      _users.completeOnboarding(user);

  bool get isDiagnosticDone => _users.isDiagnosticDone;

  Future<void> setDiagnosticDone(bool value) =>
      _users.setDiagnosticDone(value);

  Future<void> saveDiagnosticResult(DiagnosticResultModel result) =>
      _users.saveDiagnosticResult(result);

  DiagnosticResultModel? getDiagnosticResult() => _users.getDiagnosticResult();

  bool get hasStudyPlan => _lessons.hasStudyPlan;

  Future<void> setStudyPlanReady(bool value) =>
      _lessons.setStudyPlanReady(value);

  Future<void> saveStudyPlanBundle(StudyPlanBundle bundle) =>
      _lessons.saveStudyPlanBundle(bundle);

  StudyPlanBundle? getStudyPlanBundle() => _lessons.getStudyPlanBundle();

  Future<void> clearStudyPlan() => _lessons.clearStudyPlan();

  LessonModel? getLessonById(String id) => _lessons.getLessonById(id);

  Future<void> updateLesson(LessonModel lesson) => _lessons.updateLesson(lesson);

  Future<UnlockAttempt> applyPracticeResult({
    required LessonModel lesson,
    required double masteryPercent,
    required int coinsEarned,
  }) {
    return _apply.call(
      lesson: lesson,
      masteryPercent: masteryPercent,
      coinsEarned: coinsEarned,
    );
  }

  List<HomeworkModel> getHomeworkList() => _homework.getHomeworkList();

  Future<void> saveHomeworkList(List<HomeworkModel> items) =>
      _homework.saveHomeworkList(items);

  Future<void> upsertHomework(HomeworkModel homework) =>
      _homework.upsertHomework(homework);

  HomeworkModel? getHomeworkById(String id) => _homework.getHomeworkById(id);

  HomeworkModel? getHomeworkForLesson(String lessonId) =>
      _homework.getHomeworkForLesson(lessonId);

  List<HomeworkModel> getHomeworkListForLesson(String lessonId) =>
      _homework.getHomeworkListForLesson(lessonId);

  Future<void> deleteHomework(String id) => _homework.deleteHomework(id);

  Future<void> setPendingShellTab(int index) =>
      _snapshot.setPendingShellTab(index);

  int? takePendingShellTab() => _snapshot.takePendingShellTab();

  List<HomeworkModel> get pendingHomework => _homework.pendingHomework;

  List<HomeworkModel> get overdueHomework => _homework.overdueHomework;

  List<ExamResultModel> getExamResults() => _exams.getExamResults();

  Future<void> saveExamResult(ExamResultModel result) =>
      _exams.saveExamResult(result);

  ExamResultModel? getLatestExamResult() => _exams.getLatestExamResult();

  ExamResultModel? getExamResultForLesson(String lessonId) =>
      _exams.getExamResultForLesson(lessonId);

  Future<void> markExamWeekCompleted(int weekNumber) =>
      _lessons.markExamWeekCompleted(weekNumber);

  List<ParentAlertLogEntry> getParentAlertLogs() => _alerts.getParentAlertLogs();

  Future<void> appendParentAlertLog(ParentAlertLogEntry entry) =>
      _alerts.appendParentAlertLog(entry);

  Set<String> getOverdueAlertedIds() => _alerts.getOverdueAlertedIds();

  Future<void> markOverdueAlerted(String homeworkId) =>
      _alerts.markOverdueAlerted(homeworkId);

  String? get streakAlertDay => _alerts.streakAlertDay;

  Future<void> setStreakAlertDay(String dayKey) =>
      _alerts.setStreakAlertDay(dayKey);

  Set<String> getUnlockedAvatarIds() => _gamification.getUnlockedAvatarIds();

  Future<void> unlockAvatars(List<String> ids) =>
      _gamification.unlockAvatars(ids);

  Future<void> setSelectedAvatar(String avatarId) =>
      _gamification.setSelectedAvatar(avatarId);

  int getWeeklyXp() => _gamification.getWeeklyXp();

  Future<void> addWeeklyXp(int xp) => _gamification.addWeeklyXp(xp);

  Future<GamificationReward?> recordDailyOpen() =>
      _gamification.recordDailyOpen();

  Future<void> resetAll() => _snapshot.resetAll();
}
