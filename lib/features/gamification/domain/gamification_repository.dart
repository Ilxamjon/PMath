import 'gamification_reward.dart';

/// Avatar va haftalik XP. Mukofot hisobi chaqiruvchi use-case da.
abstract class GamificationRepository {
  Set<String> getUnlockedAvatarIds();

  Future<void> unlockAvatars(List<String> ids);

  Future<void> setSelectedAvatar(String avatarId);

  int getWeeklyXp();

  Future<void> addWeeklyXp(int xp);

  Future<GamificationReward?> recordDailyOpen();
}
