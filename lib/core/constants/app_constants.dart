/// Global biznes qoidalari va konstantalar.
abstract final class AppConstants {
  /// Mastery Lock: keyingi darsga o‘tish uchun minimal foiz.
  static const double masteryLockThreshold = 80.0;

  /// Bepul sinov muddati (kun).
  static const int freeTrialDays = 7;

  /// Obuna narxlari (UZS).
  static const int monthlyPriceUzs = 30000;
  static const int sixMonthPriceUzs = 120000;

  /// Diagnostik test savollari soni.
  static const int diagnosticQuestionCount = 10;

  /// Diagnostik test umumiy vaqti (daqiqa).
  static const int diagnosticDurationMinutes = 10;

  /// Kategoriya "zaif" deb hisoblanadigan yuqori chegarasi (%).
  static const double weakCategoryThreshold = 60.0;

  /// Kategoriya "kuchli" deb hisoblanadigan pastki chegarasi (%).
  static const double strongCategoryThreshold = 80.0;

  /// Har bir darsdan keyin mashqlar: 5 oson + 5 o‘rtacha + 5 qiyin.
  static const int practiceEasyCount = 5;
  static const int practiceMediumCount = 5;
  static const int practiceHardCount = 5;
  static const int practiceExerciseMin = 15;
  static const int practiceExerciseMax = 15;

  /// Uyga vazifa soni (har xil daraja).
  static const int homeworkPerLesson = 15;

  /// O‘quv rejasi davomiyligi (oy).
  static const int studyPlanMonths = 6;

  /// 6 oy ≈ 24 hafta.
  static const int studyPlanWeeks = 24;

  /// Oddiy haftada darslar soni.
  static const int lessonsPerWeek = 2;

  /// Har N-haftada imtihon.
  static const int examEveryNWeeks = 4;

  /// Mini-imtihon savollari soni.
  static const int examQuestionCount = 10;

  /// Mini-imtihon vaqti (daqiqa).
  static const int examDurationMinutes = 25;

  /// Yozma uyga vazifa muddati (kun).
  static const int homeworkDueDays = 1;

  /// Hive box nomlari.
  static const String userBox = 'user_box';
  static const String lessonsBox = 'lessons_box';
  static const String homeworkBox = 'homework_box';
  static const String prefsBox = 'prefs_box';
}
