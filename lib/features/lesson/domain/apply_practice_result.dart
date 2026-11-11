import '../../../core/utils/mastery_helper.dart';
import '../../../models/lesson_model.dart';
import '../../../services/gamification_service.dart';
import '../../gamification/domain/gamification_repository.dart';
import '../../user/domain/user_repository.dart';
import 'lesson_repository.dart';

/// Mashq natijasini qo‘llash: mastery, tangalar, XP, streak, keyingi dars.
///
/// Saqlash repository larda. Bu sinf hisoblaydi, o‘zi diskka yozmaydi.
class ApplyPracticeResult {
  ApplyPracticeResult({
    required LessonRepository lessons,
    required UserRepository users,
    required GamificationRepository gamification,
    DateTime Function()? now,
    GamificationService? game,
  })  : _lessons = lessons,
        _users = users,
        _gamification = gamification,
        _now = now ?? DateTime.now,
        _game = game ?? GamificationService();

  final LessonRepository _lessons;
  final UserRepository _users;
  final GamificationRepository _gamification;
  final DateTime Function() _now;
  final GamificationService _game;

  Future<UnlockAttempt> call({
    required LessonModel lesson,
    required double masteryPercent,
    required int coinsEarned,
  }) async {
    // TODO(retry): mastery 80% dan past bo‘lsa ham dars `completed` qilinadi.
    // Qayta urinish alohida oqim bo‘lishi kerak (darsni qayta ochish).
    // Hozirgi xulq-atvor saqlanadi — bu yerni o‘zgartirmang.
    final updatedLesson = lesson.copyWith(
      status: LessonStatus.completed,
      masteryPercent: masteryPercent,
      completedAt: _now(),
    );
    await _lessons.updateLesson(updatedLesson);

    final user = _users.getUser();
    if (user != null) {
      final studyAdd = lesson.durationMinutes > 0 ? lesson.durationMinutes : 15;
      final reward = _game.applyReward(
        user: user,
        unlockedAvatarIds: _gamification.getUnlockedAvatarIds(),
        coins: coinsEarned > 0 ? coinsEarned : 0,
        now: _now(),
      );
      await _users.saveUser(
        reward.user.copyWith(
          totalStudyMinutes: user.totalStudyMinutes + studyAdd,
        ),
      );
      await _gamification.addWeeklyXp(reward.xpGained);
      if (reward.newlyUnlockedAvatars.isNotEmpty) {
        await _gamification.unlockAvatars(
          reward.newlyUnlockedAvatars.map((a) => a.id).toList(),
        );
      }
    }

    if (!MasteryHelper.isMastered(masteryPercent)) {
      return UnlockAttempt.failedMastery;
    }

    final freshUser = _users.getUser();
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

    final unlocked = await _lessons.unlockNextLesson(updatedLesson);
    return unlocked ? UnlockAttempt.success : UnlockAttempt.noNext;
  }
}
