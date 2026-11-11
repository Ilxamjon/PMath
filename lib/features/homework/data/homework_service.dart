import '../../../models/grading_result.dart';
import '../../../models/homework_model.dart';
import '../../../models/lesson_model.dart';
import '../../../models/user_model.dart';
import '../../../models/vision_analysis_result.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/mastery_helper.dart';
import '../../../services/parent_alert_service.dart';
import '../../../services/storage_service.dart';
import '../domain/homework_assigner.dart';

/// Uyga vazifa berish, muddat, ota-ona eslatma.
class HomeworkService {
  HomeworkService({
    required StorageService storage,
    required ParentAlertService alerts,
  })  : _storage = storage,
        _alerts = alerts;

  final StorageService _storage;
  final ParentAlertService _alerts;

  /// Dars uchun 15 ta yozma vazifa (agar hali to‘liq to‘plam yo‘q bo‘lsa).
  Future<List<HomeworkModel>> assignForLesson(LessonModel lesson) async {
    final existing = _storage.getHomeworkListForLesson(lesson.id);
    final pending = existing
        .where((h) =>
            h.status == HomeworkStatus.assigned ||
            h.status == HomeworkStatus.needsRevision)
        .toList();
    if (pending.length >= AppConstants.homeworkPerLesson) {
      return pending;
    }

    // Eski bitta vazifa bo‘lsa — to‘liq to‘plamga yangilaymiz.
    for (final h in pending) {
      await _storage.deleteHomework(h.id);
    }

    final set = HomeworkAssigner.setForLesson(lesson);
    for (final hw in set) {
      await _storage.upsertHomework(hw);
    }

    final user = _storage.getUser();
    if (user != null && set.isNotEmpty) {
      await _alerts.homeworkAssigned(user: user, homework: set.first);
    }
    return set;
  }

  /// Bitta vazifa (eski chaqiriqlar uchun).
  Future<HomeworkModel> assignOneForLesson(LessonModel lesson) async {
    final list = await assignForLesson(lesson);
    return list.first;
  }

  /// Muddati o‘tgan vazifalar uchun ota-ona + streak ogohlantirish.
  /// Har vazifa uchun bir marta (dedupe).
  Future<int> checkOverdueAndAlert() async {
    final user = _storage.getUser();
    if (user == null) return 0;

    final already = _storage.getOverdueAlertedIds();
    var count = 0;
    for (final hw in _storage.overdueHomework) {
      if (already.contains(hw.id)) continue;
      count++;
      await _alerts.homeworkOverdue(user: user, homework: hw);
      await _alerts.streakAtRisk(
        user: user,
        reasonUz: 'Uyga vazifa muddati o‘tdi: ${hw.titleUz}',
      );
      await _storage.markOverdueAlerted(hw.id);
    }
    return count;
  }

  Future<HomeworkModel> markSubmitted(HomeworkModel homework) async {
    final updated = homework.copyWith(
      status: HomeworkStatus.submitted,
      submittedAt: DateTime.now(),
      type: HomeworkType.scanned,
    );
    await _storage.upsertHomework(updated);
    return updated;
  }

  /// Rasm + Vision AI → qadamlar JSON, status: grading.
  Future<HomeworkModel> applyVisionScan({
    required HomeworkModel homework,
    required VisionAnalysisResult analysis,
  }) async {
    final updated = homework.copyWith(
      imagePath: null,
      clearImagePath: true,
      extractedSteps: analysis.steps,
      ocrRawText: analysis.rawText,
      visionConfidence: analysis.confidence,
      status: HomeworkStatus.grading,
      submittedAt: DateTime.now(),
      type: HomeworkType.scanned,
      aiFeedbackUz:
          'Vision AI (${analysis.modelName}) ${analysis.steps.length} ta qadam ajratdi.',
    );
    await _storage.upsertHomework(updated);
    return updated;
  }

  /// Tasdiqlangan qadamlarni baholashdan oldin saqlaydi.
  Future<HomeworkModel> replaceExtractedSteps({
    required HomeworkModel homework,
    required List<String> steps,
  }) async {
    final updated = homework.copyWith(
      extractedSteps: steps,
      clearImagePath: true,
      status: HomeworkStatus.grading,
    );
    await _storage.upsertHomework(updated);
    return updated;
  }

  /// AI baholash natijasini saqlash + dars mastery + tangalar.
  ///
  /// Returns: (homework, nextLessonUnlocked).
  Future<(HomeworkModel, bool)> applyGrade({
    required HomeworkModel homework,
    required GradingResult result,
  }) async {
    final status = result.isPassed
        ? HomeworkStatus.graded
        : HomeworkStatus.needsRevision;

    final updated = homework.copyWith(
      status: status,
      masteryPercent: result.masteryPercent,
      errorSteps: result.errorSteps,
      gradedAt: DateTime.now(),
      aiFeedbackUz: result.feedbackUz,
    );
    await _storage.upsertHomework(updated);

    var unlocked = false;
    final lesson = _storage.getLessonById(homework.lessonId);
    if (lesson != null) {
      // Uyga vazifa mastery dars mastery bilan birlashtiriladi (max).
      final blended = result.masteryPercent > lesson.masteryPercent
          ? result.masteryPercent
          : lesson.masteryPercent;

      if (MasteryHelper.isMastered(blended)) {
        final attempt = await _storage.applyPracticeResult(
          lesson: lesson,
          masteryPercent: blended,
          coinsEarned: result.coinsEarned,
        );
        unlocked = attempt.unlocked;
      } else if (result.coinsEarned > 0) {
        final user = _storage.getUser();
        if (user != null) {
          await _storage.saveUser(
            user.copyWith(
              coins: user.coins + result.coinsEarned,
              lastActiveDate: DateTime.now(),
            ),
          );
        }
        await _storage.updateLesson(
          lesson.copyWith(masteryPercent: blended),
        );
      } else {
        await _storage.updateLesson(
          lesson.copyWith(masteryPercent: blended),
        );
      }
    } else if (result.coinsEarned > 0) {
      final user = _storage.getUser();
      if (user != null) {
        await _storage.saveUser(
          user.copyWith(
            coins: user.coins + result.coinsEarned,
            lastActiveDate: DateTime.now(),
          ),
        );
      }
    }

    final user = _storage.getUser();
    if (user != null) {
      await _alerts.homeworkGraded(
        user: user,
        homework: updated,
      );
    }

    return (updated, unlocked);
  }

  UserModel? get user => _storage.getUser();

  HomeworkModel? getById(String id) => _storage.getHomeworkById(id);
}
