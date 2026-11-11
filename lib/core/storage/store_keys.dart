/// SharedPreferences kalitlari. Migratsiya shu nomlarni o‘qiydi.
abstract final class PrefsKeys {
  static const user = 'pmath_user';
  static const onboardingDone = 'pmath_onboarding_done';
  static const diagnosticDone = 'pmath_diagnostic_done';
  static const diagnosticResult = 'pmath_diagnostic_result';
  static const studyPlanReady = 'pmath_study_plan_ready';
  static const studyPlan = 'pmath_study_plan_bundle';
  static const homeworkList = 'pmath_homework_list';
  static const examResults = 'pmath_exam_results';
  static const parentAlerts = 'pmath_parent_alerts';
  static const overdueAlerted = 'pmath_overdue_alerted_ids';
  static const streakAlertDay = 'pmath_streak_alert_day';
  static const unlockedAvatars = 'pmath_unlocked_avatars';
  static const weeklyXp = 'pmath_weekly_xp';
  static const weeklyXpWeek = 'pmath_weekly_xp_week';
  static const pendingShellTab = 'pmath_pending_shell_tab';
}

/// SQLite ichidagi mantiqiy kalitlar.
abstract final class StoreKeys {
  /// Prefs dan bir marta ko‘chirish belgisi. Drift `schemaVersion` dan alohida.
  static const prefsImportVersion = 'prefs_import_version';
  static const currentImportVersion = '1';

  static const onboardingDone = 'onboarding_done';
  static const diagnosticDone = 'diagnostic_done';
  static const studyPlanReady = 'study_plan_ready';
  static const streakAlertDay = 'streak_alert_day';
  static const weeklyXp = 'weekly_xp';
  static const weeklyXpWeek = 'weekly_xp_week';
  static const pendingShellTab = 'pending_shell_tab';

  static const docUser = 'user';
  static const docDiagnostic = 'diagnostic';
  static const docStudyPlan = 'study_plan';

  static const bucketAvatars = 'avatars';
  static const bucketOverdue = 'overdue';
}
