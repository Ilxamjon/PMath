import 'package:equatable/equatable.dart';

import '../../../models/user_model.dart';
import 'avatar_catalog.dart';

/// Faollik / mukofot natijasi.
class GamificationReward extends Equatable {
  const GamificationReward({
    required this.user,
    this.coinsGained = 0,
    this.xpGained = 0,
    this.streakIncreased = false,
    this.leveledUp = false,
    this.newlyUnlockedAvatars = const [],
  });

  final UserModel user;
  final int coinsGained;
  final int xpGained;
  final bool streakIncreased;
  final bool leveledUp;
  final List<AvatarDef> newlyUnlockedAvatars;

  @override
  List<Object?> get props => [
        user,
        coinsGained,
        xpGained,
        streakIncreased,
        leveledUp,
        newlyUnlockedAvatars,
      ];
}
