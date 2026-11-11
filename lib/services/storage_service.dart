import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/iso_week.dart';
import '../core/utils/mastery_helper.dart';
import '../features/gamification/domain/avatar_catalog.dart';
import '../features/gamification/domain/gamification_reward.dart';
import '../models/diagnostic_result_model.dart';
import '../models/exam_result_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/parent_alert_log.dart';
import '../models/study_plan_bundle.dart';
import '../models/study_plan_model.dart';
import '../models/user_model.dart';
import 'gamification_service.dart';

/// Lokal saqlash — shared_preferences asosida (Hive keyinroq kengaytiriladi).
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _userKey = 'pmath_user';
  static const _onboardingDoneKey = 'pmath_onboarding_done';
  static const _diagnosticDoneKey = 'pmath_diagnostic_done';
  static const _diagnosticResultKey = 'pmath_diagnostic_result';
  static const _studyPlanReadyKey = 'pmath_study_plan_ready';
  static const _studyPlanKey = 'pmath_study_plan_bundle';
  static const _homeworkListKey = 'pmath_homework_list';
  static const _examResultsKey = 'pmath_exam_results';
  static const _parentAlertsKey = 'pmath_parent_alerts';
  static const _overdueAlertedKey = 'pmath_overdue_alerted_ids';
  static const _streakAlertDayKey = 'pmath_streak_alert_day';
  static const _unlockedAvatarsKey = 'pmath_unlocked_avatars';
  static const _weeklyXpKey = 'pmath_weekly_xp';
  static const _weeklyXpWeekKey = 'pmath_weekly_xp_week';

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Nazorat ogohlantirishi: +1 va yangilangan son.
  Future<int> recordCheatingWarning() async {
    final user = getUser();
    if (user == null) return 0;
    final next = user.cheatingWarnings + 1;
    await saveUser(user.copyWith(cheatingWarnings: next));
    return next;
  }

  UserModel? getUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  bool get isOnboardingDone => _prefs.getBool(_onboardingDoneKey) ?? false;

  Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool(_onboardingDoneKey, value);
  }

  Future<void> completeOnboarding(UserModel user) async {
    await saveUser(user);
    await setOnboardingDone(true);
  }

  // —— Diagnostik ——

  bool get isDiagnosticDone => _prefs.getBool(_diagnosticDoneKey) ?? false;

  Future<void> setDiagnosticDone(bool value) async {
    await _prefs.setBool(_diagnosticDoneKey, value);
  }

  Future<void> saveDiagnosticResult(DiagnosticResultModel result) async {
    await _prefs.setString(
      _diagnosticResultKey,
      jsonEncode(result.toJson()),
    );
  }

  DiagnosticResultModel? getDiagnosticResult() {
    final raw = _prefs.getString(_diagnosticResultKey);
    if (raw == null) return null;
    return DiagnosticResultModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // —— Study plan / AI roadmap ——

  bool get hasStudyPlan => _prefs.getBool(_studyPlanReadyKey) ?? false;

  Future<void> setStudyPlanReady(bool value) async {
    await _prefs.setBool(_studyPlanReadyKey, value);
  }

  Future<void> saveStudyPlanBundle(StudyPlanBundle bundle) async {
    await _prefs.setString(_studyPlanKey, jsonEncode(bundle.toJson()));
  }

  StudyPlanBundle? getStudyPlanBundle() {
    final raw = _prefs.getString(_studyPlanKey);
    if (raw == null) return null;
    return StudyPlanBundle.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clearStudyPlan() async {
    await setStudyPlanReady(false);
    await _prefs.remove(_studyPlanKey);
  }

  LessonModel? getLessonById(String id) {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return null;
    try {
      return bundle.lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Dars holatini yangilash (inProgress / completed / mastery).
  Future<void> updateLesson(LessonModel lesson) async {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return;

    final updatedLessons = bundle.lessons.map((l) {
      return l.id == lesson.id ? lesson : l;
    }).toList();

    await saveStudyPlanBundle(
      StudyPlanBundle(plan: bundle.plan, lessons: updatedLessons),
    );
  }

  /// Mashq natijasini qo‘llash: mastery, tangalar, XP, streak, keyingi dars.
  Future<UnlockAttempt> applyPracticeResult({
    required LessonModel lesson,
    required double masteryPercent,
    required int coinsEarned,
  }) async {
    final updatedLesson = lesson.copyWith(
      status: LessonStatus.completed,
      masteryPercent: masteryPercent,
      completedAt: DateTime.now(),
    );
    await updateLesson(updatedLesson);

    final user = getUser();
    if (user != null) {
      final studyAdd = lesson.durationMinutes > 0 ? lesson.durationMinutes : 15;
      final game = GamificationService();
      final reward = game.applyReward(
        user: user,
        unlockedAvatarIds: getUnlockedAvatarIds(),
        coins: coinsEarned > 0 ? coinsEarned : 0,
      );
      await saveUser(
        reward.user.copyWith(
          totalStudyMinutes: user.totalStudyMinutes + studyAdd,
        ),
      );
      await addWeeklyXp(reward.xpGained);
      if (reward.newlyUnlockedAvatars.isNotEmpty) {
        await unlockAvatars(
          reward.newlyUnlockedAvatars.map((a) => a.id).toList(),
        );
      }
    }

    if (!MasteryHelper.isMastered(masteryPercent)) {
      return UnlockAttempt.failedMastery;
    }

    final freshUser = getUser();
    if (freshUser == null) return UnlockAttempt.noNext;

    final block = MasteryHelper.reasonBlockingUnlock(
      currentMastery: masteryPercent,
      user: freshUser,
    );
    if (block == LockBlockReason.subscriptionRequired) {
      return UnlockAttempt.failedSubscription;
    }
    if (block != LockBlockReason.none) {
      return UnlockAttempt.failedMastery;
    }

    final unlocked = await _unlockNextLesson(updatedLesson);
    return unlocked ? UnlockAttempt.success : UnlockAttempt.noNext;
  }

  Future<bool> _unlockNextLesson(LessonModel current) async {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return false;

    final sorted = [...bundle.lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final idx = sorted.indexWhere((l) => l.id == current.id);
    if (idx < 0 || idx >= sorted.length - 1) return false;

    final next = sorted[idx + 1];
    if (next.status != LessonStatus.locked) return false;

    final unlockedNext = next.copyWith(status: LessonStatus.available);
    final updatedLessons = bundle.lessons.map((l) {
      if (l.id == current.id) return current;
      if (l.id == next.id) return unlockedNext;
      return l;
    }).toList();

    await saveStudyPlanBundle(
      StudyPlanBundle(plan: bundle.plan, lessons: updatedLessons),
    );
    return true;
  }

  // —— Uyga vazifa ——

  List<HomeworkModel> getHomeworkList() {
    final raw = _prefs.getString(_homeworkListKey);
    if (raw == null) return <HomeworkModel>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HomeworkModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
  }

  Future<void> saveHomeworkList(List<HomeworkModel> items) async {
    await _prefs.setString(
      _homeworkListKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> upsertHomework(HomeworkModel homework) async {
    final list = [...getHomeworkList()];
    final idx = list.indexWhere((h) => h.id == homework.id);
    if (idx >= 0) {
      list[idx] = homework;
    } else {
      list.insert(0, homework);
    }
    await saveHomeworkList(list);
  }

  HomeworkModel? getHomeworkById(String id) {
    try {
      return getHomeworkList().firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  HomeworkModel? getHomeworkForLesson(String lessonId) {
    try {
      return getHomeworkList().firstWhere(
        (h) =>
            h.lessonId == lessonId &&
            (h.status == HomeworkStatus.assigned ||
                h.status == HomeworkStatus.needsRevision),
      );
    } catch (_) {
      return null;
    }
  }

  List<HomeworkModel> getHomeworkListForLesson(String lessonId) {
    return getHomeworkList().where((h) => h.lessonId == lessonId).toList();
  }

  Future<void> deleteHomework(String id) async {
    final list = getHomeworkList().where((h) => h.id != id).toList();
    await saveHomeworkList(list);
  }

  /// Asosiy shell tab (0=xarita, 1=skaner, 2=ota-ona).
  static const _pendingShellTabKey = 'pmath_pending_shell_tab';

  Future<void> setPendingShellTab(int index) async {
    await _prefs.setInt(_pendingShellTabKey, index);
  }

  int? takePendingShellTab() {
    final v = _prefs.getInt(_pendingShellTabKey);
    if (v != null) {
      _prefs.remove(_pendingShellTabKey);
    }
    return v;
  }

  List<HomeworkModel> get pendingHomework =>
      getHomeworkList().where((h) => h.isPendingScan).toList();

  List<HomeworkModel> get overdueHomework =>
      getHomeworkList().where((h) => h.isOverdue).toList();

  // —— Imtihonlar ——

  List<ExamResultModel> getExamResults() {
    final raw = _prefs.getString(_examResultsKey);
    if (raw == null) return <ExamResultModel>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ExamResultModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> saveExamResult(ExamResultModel result) async {
    final list = List<ExamResultModel>.from(getExamResults());
    list.insert(0, result);
    await _prefs.setString(
      _examResultsKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  ExamResultModel? getLatestExamResult() {
    final list = getExamResults();
    return list.isEmpty ? null : list.first;
  }

  ExamResultModel? getExamResultForLesson(String lessonId) {
    try {
      return getExamResults().firstWhere((e) => e.lessonId == lessonId);
    } catch (_) {
      return null;
    }
  }

  /// `isExamWeek` haftani completed qilish.
  Future<void> markExamWeekCompleted(int weekNumber) async {
    final bundle = getStudyPlanBundle();
    if (bundle == null) return;

    final weeks = bundle.plan.weeks.map((w) {
      if (w.weekNumber == weekNumber && w.isExamWeek) {
        return WeeklyPlan(
          weekNumber: w.weekNumber,
          titleUz: w.titleUz,
          focusTopics: w.focusTopics,
          lessonIds: w.lessonIds,
          isExamWeek: w.isExamWeek,
          completed: true,
        );
      }
      return w;
    }).toList();

    final plan = bundle.plan.copyWith(weeks: weeks);
    await saveStudyPlanBundle(
      StudyPlanBundle(plan: plan, lessons: bundle.lessons),
    );
  }

  // —— Ota-ona Telegram jurnal ——

  List<ParentAlertLogEntry> getParentAlertLogs() {
    final raw = _prefs.getString(_parentAlertsKey);
    if (raw == null) return <ParentAlertLogEntry>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ParentAlertLogEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> appendParentAlertLog(ParentAlertLogEntry entry) async {
    final list = List<ParentAlertLogEntry>.from(getParentAlertLogs());
    list.insert(0, entry);
    final trimmed = list.take(50).toList();
    await _prefs.setString(
      _parentAlertsKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Set<String> getOverdueAlertedIds() {
    final raw = _prefs.getStringList(_overdueAlertedKey) ?? const [];
    return raw.toSet();
  }

  Future<void> markOverdueAlerted(String homeworkId) async {
    final ids = getOverdueAlertedIds()..add(homeworkId);
    await _prefs.setStringList(_overdueAlertedKey, ids.toList());
  }

  /// Bugun streak alert yuborilganmi? (`yyyy-MM-dd`)
  String? get streakAlertDay => _prefs.getString(_streakAlertDayKey);

  Future<void> setStreakAlertDay(String dayKey) async {
    await _prefs.setString(_streakAlertDayKey, dayKey);
  }

  // —— Gamification: avatar + haftalik XP ——

  Set<String> getUnlockedAvatarIds() {
    final raw = _prefs.getStringList(_unlockedAvatarsKey) ?? const ['default'];
    return {...raw, 'default'};
  }

  Future<void> unlockAvatars(List<String> ids) async {
    final set = getUnlockedAvatarIds()..addAll(ids);
    await _prefs.setStringList(_unlockedAvatarsKey, set.toList());
  }

  Future<void> setSelectedAvatar(String avatarId) async {
    final user = getUser();
    if (user == null) return;
    final unlocked = getUnlockedAvatarIds();
    final def = AvatarCatalog.byId(avatarId);
    final ok = def.isUnlocked(
      streakDays: user.streakDays,
      level: user.level,
      coins: user.coins,
      unlockedIds: unlocked,
    );
    if (!ok) return;
    if (!unlocked.contains(avatarId)) {
      await unlockAvatars([avatarId]);
    }
    await saveUser(user.copyWith(avatarId: avatarId));
  }

  /// ISO-8601 hafta kaliti (yil chegarasida ham to‘g‘ri).
  String _currentWeekKey() => isoWeekKey(DateTime.now());

  int getWeeklyXp() {
    final week = _prefs.getString(_weeklyXpWeekKey);
    final current = _currentWeekKey();
    if (week != current) return 0;
    return _prefs.getInt(_weeklyXpKey) ?? 0;
  }

  Future<void> addWeeklyXp(int xp) async {
    final current = _currentWeekKey();
    final week = _prefs.getString(_weeklyXpWeekKey);
    var value = 0;
    if (week == current) {
      value = _prefs.getInt(_weeklyXpKey) ?? 0;
    }
    await _prefs.setString(_weeklyXpWeekKey, current);
    await _prefs.setInt(_weeklyXpKey, value + xp);
  }

  /// Kunlik ochilish — streak saqlash.
  Future<GamificationReward?> recordDailyOpen() async {
    final user = getUser();
    if (user == null) return null;
    final game = GamificationService();
    final reward = game.applyDailyActivity(
      user: user,
      unlockedAvatarIds: getUnlockedAvatarIds(),
    );
    await saveUser(reward.user);
    await addWeeklyXp(reward.xpGained);
    if (reward.newlyUnlockedAvatars.isNotEmpty) {
      await unlockAvatars(
        reward.newlyUnlockedAvatars.map((a) => a.id).toList(),
      );
    }
    return reward;
  }

  /// Dev / test uchun tozalash.
  Future<void> resetAll() async {
    await clearUser();
    await setOnboardingDone(false);
    await setDiagnosticDone(false);
    await _prefs.remove(_diagnosticResultKey);
    await clearStudyPlan();
    await _prefs.remove(_homeworkListKey);
    await _prefs.remove(_examResultsKey);
    await _prefs.remove(_parentAlertsKey);
    await _prefs.remove(_overdueAlertedKey);
    await _prefs.remove(_streakAlertDayKey);
    await _prefs.remove(_unlockedAvatarsKey);
    await _prefs.remove(_weeklyXpKey);
    await _prefs.remove(_weeklyXpWeekKey);
  }
}
