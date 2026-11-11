import '../../../core/storage/local_snapshot.dart';
import '../../../core/utils/iso_week.dart';
import '../../../services/gamification_service.dart';
import '../../user/domain/user_repository.dart';
import '../domain/avatar_catalog.dart';
import '../domain/gamification_repository.dart';
import '../domain/gamification_reward.dart';

class DriftGamificationRepository implements GamificationRepository {
  DriftGamificationRepository(this._store, this._users, {GamificationService? game})
      : _game = game ?? GamificationService();

  final LocalSnapshot _store;
  final UserRepository _users;
  final GamificationService _game;

  @override
  Set<String> getUnlockedAvatarIds() => {..._store.avatarIds, 'default'};

  @override
  Future<void> unlockAvatars(List<String> ids) async {
    final set = getUnlockedAvatarIds()..addAll(ids);
    await _store.saveAvatarIds(set);
  }

  @override
  Future<void> setSelectedAvatar(String avatarId) async {
    final user = _users.getUser();
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
    await _users.saveUser(user.copyWith(avatarId: avatarId));
  }

  @override
  int getWeeklyXp() {
    final current = isoWeekKey(_store.now());
    if (_store.weeklyXpWeek != current) return 0;
    return _store.weeklyXp;
  }

  @override
  Future<void> addWeeklyXp(int xp) async {
    final current = isoWeekKey(_store.now());
    var value = 0;
    if (_store.weeklyXpWeek == current) {
      value = _store.weeklyXp;
    }
    await _store.saveWeeklyXp(xp: value + xp, week: current);
  }

  @override
  Future<GamificationReward?> recordDailyOpen() async {
    final user = _users.getUser();
    if (user == null) return null;
    final reward = _game.applyDailyActivity(
      user: user,
      unlockedAvatarIds: getUnlockedAvatarIds(),
    );
    await _users.saveUser(reward.user);
    await addWeeklyXp(reward.xpGained);
    if (reward.newlyUnlockedAvatars.isNotEmpty) {
      await unlockAvatars(
        reward.newlyUnlockedAvatars.map((avatar) => avatar.id).toList(),
      );
    }
    return reward;
  }
}
