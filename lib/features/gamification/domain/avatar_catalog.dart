import 'package:equatable/equatable.dart';

/// Avatar ochilish sharti.
enum AvatarUnlockRule {
  free,
  streak,
  level,
  coins,
}

/// Katalogdagi avatar.
class AvatarDef extends Equatable {
  const AvatarDef({
    required this.id,
    required this.emoji,
    required this.nameUz,
    this.rule = AvatarUnlockRule.free,
    this.threshold = 0,
  });

  final String id;
  final String emoji;
  final String nameUz;
  final AvatarUnlockRule rule;
  final int threshold;

  String unlockHintUz() {
    return switch (rule) {
      AvatarUnlockRule.free => 'Bepul',
      AvatarUnlockRule.streak => '$threshold kunlik streak',
      AvatarUnlockRule.level => '$threshold-daraja',
      AvatarUnlockRule.coins => '$threshold tanga',
    };
  }

  bool isUnlocked({
    required int streakDays,
    required int level,
    required int coins,
    required Set<String> unlockedIds,
  }) {
    if (rule == AvatarUnlockRule.free) return true;
    if (unlockedIds.contains(id)) return true;
    return switch (rule) {
      AvatarUnlockRule.free => true,
      AvatarUnlockRule.streak => streakDays >= threshold,
      AvatarUnlockRule.level => level >= threshold,
      AvatarUnlockRule.coins => coins >= threshold,
    };
  }

  @override
  List<Object?> get props => [id, emoji, nameUz, rule, threshold];
}

/// Barcha avatarlar.
abstract final class AvatarCatalog {
  static const all = <AvatarDef>[
    AvatarDef(id: 'default', emoji: '🧒', nameUz: 'Boshlovchi'),
    AvatarDef(
      id: 'fox',
      emoji: '🦊',
      nameUz: 'Aqlli tulki',
      rule: AvatarUnlockRule.streak,
      threshold: 3,
    ),
    AvatarDef(
      id: 'owl',
      emoji: '🦉',
      nameUz: 'Donishmand boyqush',
      rule: AvatarUnlockRule.streak,
      threshold: 7,
    ),
    AvatarDef(
      id: 'rocket',
      emoji: '🚀',
      nameUz: 'Raketa',
      rule: AvatarUnlockRule.level,
      threshold: 3,
    ),
    AvatarDef(
      id: 'crown',
      emoji: '👑',
      nameUz: 'Chempion',
      rule: AvatarUnlockRule.level,
      threshold: 5,
    ),
    AvatarDef(
      id: 'dragon',
      emoji: '🐉',
      nameUz: 'Matematik ajdar',
      rule: AvatarUnlockRule.coins,
      threshold: 200,
    ),
    AvatarDef(
      id: 'star',
      emoji: '⭐',
      nameUz: 'Yulduz',
      rule: AvatarUnlockRule.coins,
      threshold: 500,
    ),
  ];

  static AvatarDef byId(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => all.first,
    );
  }
}

/// Haftalik liga qatori.
class LeagueBoardEntry extends Equatable {
  const LeagueBoardEntry({
    required this.rank,
    required this.nameUz,
    required this.weeklyXp,
    required this.isMe,
    this.avatarEmoji = '🧒',
  });

  final int rank;
  final String nameUz;
  final int weeklyXp;
  final bool isMe;
  final String avatarEmoji;

  @override
  List<Object?> get props => [rank, nameUz, weeklyXp, isMe, avatarEmoji];
}
