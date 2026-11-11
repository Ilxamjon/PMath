import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/gamification/domain/avatar_catalog.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/gamification_service.dart';

void main() {
  test('Gamification streak: kechagi faollik +1', () {
    final game = GamificationService();
    final now = DateTime(2026, 7, 24, 10);
    expect(
      game.updateStreak(
        currentStreak: 4,
        lastActive: DateTime(2026, 7, 23, 18),
        now: now,
      ),
      5,
    );
    expect(
      game.updateStreak(
        currentStreak: 4,
        lastActive: now,
        now: now,
      ),
      4,
    );
    expect(
      game.updateStreak(
        currentStreak: 4,
        lastActive: DateTime(2026, 7, 20),
        now: now,
      ),
      1,
    );
  });

  test('streak aynan 1 kun o‘tsa davom etadi, 2 kunda uziladi', () {
    final game = GamificationService();
    final now = DateTime(2026, 7, 24, 23);
    expect(
      game.updateStreak(
        currentStreak: 6,
        lastActive: DateTime(2026, 7, 23, 0),
        now: now,
      ),
      7,
    );
    expect(
      game.updateStreak(
        currentStreak: 6,
        lastActive: DateTime(2026, 7, 22, 23),
        now: now,
      ),
      1,
    );
  });

  test('level 99 XP da 1, 100 XP da 2, 200 XP da 3', () {
    final game = GamificationService();
    expect(game.levelFromXp(0), 1);
    expect(game.levelFromXp(99), 1);
    expect(game.levelFromXp(100), 2);
    expect(game.levelFromXp(199), 2);
    expect(game.levelFromXp(200), 3);
  });

  test('mukofot 100 XP chegarasida darajani oshiradi', () {
    final game = GamificationService();
    final now = DateTime(2026, 7, 24, 10);
    final reward = game.applyReward(
      user: _user(xp: 90, lastActive: now),
      unlockedAvatarIds: {'default'},
      coins: 10,
      now: now,
    );
    expect(reward.user.xp, 110);
    expect(reward.user.level, 2);
    expect(reward.leveledUp, isTrue);
  });

  test('Avatar unlock: streak / level / coins', () {
    final fox = AvatarCatalog.byId('fox');
    expect(
      fox.isUnlocked(
        streakDays: 2,
        level: 1,
        coins: 0,
        unlockedIds: {},
      ),
      isFalse,
    );
    expect(
      fox.isUnlocked(
        streakDays: 3,
        level: 1,
        coins: 0,
        unlockedIds: {},
      ),
      isTrue,
    );

    final rocket = AvatarCatalog.byId('rocket');
    expect(
      rocket.isUnlocked(
        streakDays: 0,
        level: 3,
        coins: 0,
        unlockedIds: {},
      ),
      isTrue,
    );

    final dragon = AvatarCatalog.byId('dragon');
    expect(
      dragon.isUnlocked(
        streakDays: 0,
        level: 1,
        coins: 199,
        unlockedIds: {},
      ),
      isFalse,
    );
    expect(
      dragon.isUnlocked(
        streakDays: 0,
        level: 1,
        coins: 200,
        unlockedIds: {},
      ),
      isTrue,
    );
  });

  test('199 tangada ajdar yopiq, 200 da ochiladi', () {
    final game = GamificationService();
    final now = DateTime(2026, 7, 24, 10);
    final almost = game.applyReward(
      user: _user(coins: 189, lastActive: now),
      unlockedAvatarIds: {'default'},
      coins: 10,
      now: now,
    );
    expect(almost.user.coins, 199);
    expect(almost.newlyUnlockedAvatars.any((a) => a.id == 'dragon'), isFalse);

    final opened = game.applyReward(
      user: _user(coins: 190, lastActive: now),
      unlockedAvatarIds: {'default'},
      coins: 10,
      now: now,
    );
    expect(opened.user.coins, 200);
    expect(opened.newlyUnlockedAvatars.any((a) => a.id == 'dragon'), isTrue);
  });

  test('applyDailyActivity streak + avatar ochadi', () {
    final game = GamificationService();
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: DateTime(2026, 7, 1),
      streakDays: 2,
      lastActiveDate: DateTime(2026, 7, 23),
      coins: 0,
      xp: 0,
      level: 1,
    );

    final reward = game.applyDailyActivity(
      user: user,
      unlockedAvatarIds: {'default'},
      now: DateTime(2026, 7, 24, 9),
    );

    expect(reward.user.streakDays, 3);
    expect(reward.streakIncreased, isTrue);
    expect(reward.coinsGained, greaterThan(0));
    expect(
      reward.newlyUnlockedAvatars.any((a) => a.id == 'fox'),
      isTrue,
    );
  });

  test('Haftalik liga: foydalanuvchi jadvalda', () {
    final game = GamificationService();
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: DateTime(2026, 7, 1),
    );
    final board = game.buildWeeklyLeaderboard(user: user, weeklyXp: 120);
    expect(board.length, 10);
    expect(board.where((e) => e.isMe).length, 1);
    expect(board.first.rank, 1);
    expect(board.last.rank, 10);
    final me = board.firstWhere((e) => e.isMe);
    expect(me.nameUz, 'Ali');
    expect(me.weeklyXp, 120);
  });
}

UserModel _user({
  int xp = 0,
  int coins = 0,
  int level = 1,
  DateTime? lastActive,
}) {
  return UserModel(
    id: 'u1',
    studentName: 'Ali',
    grade: StudentGrade.grade4,
    targetSchool: 'Prezident maktabi',
    parentPhone: '+998901234567',
    createdAt: DateTime(2026, 7, 1),
    xp: xp,
    coins: coins,
    level: level,
    streakDays: 1,
    lastActiveDate: lastActive,
  );
}
