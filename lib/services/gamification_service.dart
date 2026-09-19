import 'dart:math';

import '../../models/user_model.dart';
import '../../features/gamification/domain/avatar_catalog.dart';
import '../../features/gamification/domain/gamification_reward.dart';

/// Gamification — streak, tanga, XP/daraja, avatar, haftalik liga.
class GamificationService {
  static const int coinsPerLesson = 20;
  static const int coinsPerPerfectMastery = 50;
  static const int coinsDailyBonus = 5;
  static const int xpPerLevel = 100;
  static const int xpDailyBonus = 10;
  static const int xpPerCoin = 1;

  int levelFromXp(int xp) => (xp ~/ xpPerLevel) + 1;

  int xpProgressInLevel(int xp) => xp % xpPerLevel;

  double levelProgressPercent(int xp) => xpProgressInLevel(xp) / xpPerLevel;

  /// Ketma-ketlik yangilash: kecha faol bo‘lsa +1, bugun — o‘zgarishsiz, aks holda 1.
  int updateStreak({
    required int currentStreak,
    required DateTime? lastActive,
    required DateTime now,
  }) {
    if (lastActive == null) return 1;

    final last = DateTime(lastActive.year, lastActive.month, lastActive.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(last).inDays;

    if (diff == 0) return currentStreak <= 0 ? 1 : currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  int rewardForMastery(double masteryPercent) {
    if (masteryPercent >= 100) return coinsPerPerfectMastery;
    if (masteryPercent >= 80) return coinsPerLesson;
    return coinsPerLesson ~/ 2;
  }

  /// Kunlik ochilish / faollik — streak saqlanadi.
  GamificationReward applyDailyActivity({
    required UserModel user,
    required Set<String> unlockedAvatarIds,
    DateTime? now,
    int extraCoins = 0,
    int extraXp = 0,
  }) {
    final moment = now ?? DateTime.now();
    final prevStreak = user.streakDays;
    final newStreak = updateStreak(
      currentStreak: user.streakDays,
      lastActive: user.lastActiveDate,
      now: moment,
    );

    final sameDay = user.lastActiveDate != null &&
        _isSameDay(user.lastActiveDate!, moment);

    final coinsGain = sameDay ? extraCoins : (coinsDailyBonus + extraCoins);
    final xpGain = sameDay ? extraXp : (xpDailyBonus + extraXp);
    // Streak bonus: har 3 kunda +2 tanga
    final streakBonus =
        (!sameDay && newStreak > 0 && newStreak % 3 == 0) ? 2 : 0;

    final totalCoinsGain = coinsGain + streakBonus;
    final newCoins = user.coins + totalCoinsGain;
    final newXp = user.xp + xpGain + totalCoinsGain * xpPerCoin;
    final oldLevel = user.level;
    final newLevel = levelFromXp(newXp);

    final updated = user.copyWith(
      coins: newCoins,
      xp: newXp,
      level: newLevel,
      streakDays: newStreak,
      lastActiveDate: moment,
    );

    final newly = _unlockNewAvatars(
      user: updated,
      already: unlockedAvatarIds,
    );

    return GamificationReward(
      user: newly.isEmpty
          ? updated
          : updated.copyWith(
              // keep avatar if still valid
              avatarId: updated.avatarId,
            ),
      coinsGained: totalCoinsGain,
      xpGained: xpGain + totalCoinsGain * xpPerCoin,
      streakIncreased: newStreak > prevStreak,
      leveledUp: newLevel > oldLevel,
      newlyUnlockedAvatars: newly,
    );
  }

  /// Mashq/imtihon mukofoti + streak yangilash.
  GamificationReward applyReward({
    required UserModel user,
    required Set<String> unlockedAvatarIds,
    required int coins,
    int? xp,
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    final prevStreak = user.streakDays;
    final newStreak = updateStreak(
      currentStreak: user.streakDays,
      lastActive: user.lastActiveDate,
      now: moment,
    );

    final xpGain = xp ?? (coins * 2);
    final newCoins = user.coins + coins;
    final newXp = user.xp + xpGain;
    final oldLevel = user.level;
    final newLevel = levelFromXp(newXp);

    final updated = user.copyWith(
      coins: newCoins,
      xp: newXp,
      level: newLevel,
      streakDays: newStreak,
      lastActiveDate: moment,
    );

    final newly = _unlockNewAvatars(user: updated, already: unlockedAvatarIds);

    return GamificationReward(
      user: updated,
      coinsGained: coins,
      xpGained: xpGain,
      streakIncreased: newStreak > prevStreak,
      leveledUp: newLevel > oldLevel,
      newlyUnlockedAvatars: newly,
    );
  }

  List<AvatarDef> _unlockNewAvatars({
    required UserModel user,
    required Set<String> already,
  }) {
    final out = <AvatarDef>[];
    for (final a in AvatarCatalog.all) {
      if (already.contains(a.id)) continue;
      if (a.rule == AvatarUnlockRule.free) continue;
      if (a.isUnlocked(
        streakDays: user.streakDays,
        level: user.level,
        coins: user.coins,
        unlockedIds: already,
      )) {
        out.add(a);
      }
    }
    return out;
  }

  /// Haftalik liga: foydalanuvchi + sun’iy raqiblar.
  List<LeagueBoardEntry> buildWeeklyLeaderboard({
    required UserModel user,
    required int weeklyXp,
    int peerCount = 9,
  }) {
    final weekSeed = _isoWeekKey(DateTime.now()).hashCode ^ user.id.hashCode;
    final rng = Random(weekSeed);

    final names = [
      'Sardor',
      'Madina',
      'Jasur',
      'Dilnoza',
      'Bobur',
      'Sevinch',
      'Amir',
      'Nilufar',
      'Hasan',
      'Zarina',
      'Otabek',
      'Laylo',
    ];
    final emojis = AvatarCatalog.all.map((a) => a.emoji).toList();

    final peers = <LeagueBoardEntry>[];
    for (var i = 0; i < peerCount; i++) {
      final xp = (weeklyXp * (0.4 + rng.nextDouble() * 1.2)).round() +
          rng.nextInt(40);
      peers.add(
        LeagueBoardEntry(
          rank: 0,
          nameUz: names[rng.nextInt(names.length)],
          weeklyXp: xp.clamp(5, 9999),
          isMe: false,
          avatarEmoji: emojis[rng.nextInt(emojis.length)],
        ),
      );
    }

    final me = LeagueBoardEntry(
      rank: 0,
      nameUz: user.studentName,
      weeklyXp: weeklyXp,
      isMe: true,
      avatarEmoji: AvatarCatalog.byId(user.avatarId).emoji,
    );

    final all = [...peers, me]
      ..sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));

    return [
      for (var i = 0; i < all.length; i++)
        LeagueBoardEntry(
          rank: i + 1,
          nameUz: all[i].nameUz,
          weeklyXp: all[i].weeklyXp,
          isMe: all[i].isMe,
          avatarEmoji: all[i].avatarEmoji,
        ),
    ];
  }

  String _isoWeekKey(DateTime d) {
    // Oddiy hafta kaliti: yil + hafta raqami
    final start = DateTime(d.year);
    final dayOfYear = d.difference(start).inDays;
    final week = (dayOfYear / 7).floor() + 1;
    return '${d.year}-W$week';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
