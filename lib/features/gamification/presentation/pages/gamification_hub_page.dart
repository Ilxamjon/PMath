import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/user_model.dart';
import '../../../../services/gamification_service.dart';
import '../../../../services/storage_service.dart';
import '../../domain/avatar_catalog.dart';

/// Avatarlar + haftalik liga.
class GamificationHubPage extends StatefulWidget {
  const GamificationHubPage({super.key});

  @override
  State<GamificationHubPage> createState() => _GamificationHubPageState();
}

class _GamificationHubPageState extends State<GamificationHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final user = storage.getUser();
    if (user == null) {
      return const Scaffold(body: Center(child: Text('—')));
    }

    final game = GamificationService();
    final unlocked = storage.getUnlockedAvatarIds();
    final weeklyXp = storage.getWeeklyXp();
    final board = game.buildWeeklyLeaderboard(
      user: user,
      weeklyXp: weeklyXp,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.gamificationTitle),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: AppStrings.gamificationAvatars),
            Tab(text: AppStrings.gamificationLeague),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _AvatarsTab(
            user: user,
            unlocked: unlocked,
            onSelect: (id) async {
              await storage.setSelectedAvatar(id);
              if (mounted) setState(() {});
            },
          ),
          _LeagueTab(user: user, board: board, weeklyXp: weeklyXp, game: game),
        ],
      ),
    );
  }
}

class _AvatarsTab extends StatelessWidget {
  const _AvatarsTab({
    required this.user,
    required this.unlocked,
    required this.onSelect,
  });

  final UserModel user;
  final Set<String> unlocked;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          AppStrings.gamificationPickAvatar,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AvatarCatalog.all.map((a) {
            final open = a.isUnlocked(
              streakDays: user.streakDays,
              level: user.level,
              coins: user.coins,
              unlockedIds: unlocked,
            );
            final selected = user.avatarId == a.id;
            return InkWell(
              onTap: open ? () => onSelect(a.id) : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentSoft
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppColors.accent
                        : AppColors.surfaceAlt,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Opacity(
                      opacity: open ? 1 : 0.35,
                      child: Text(a.emoji, style: const TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.nameUz,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                    ),
                    Text(
                      open ? (selected ? '✓' : a.unlockHintUz()) : '🔒 ${a.unlockHintUz()}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LeagueTab extends StatelessWidget {
  const _LeagueTab({
    required this.user,
    required this.board,
    required this.weeklyXp,
    required this.game,
  });

  final UserModel user;
  final List<LeagueBoardEntry> board;
  final int weeklyXp;
  final GamificationService game;

  @override
  Widget build(BuildContext context) {
    final myRank = board.where((e) => e.isMe).firstOrNull?.rank ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.gamificationWeeklyXp,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '$weeklyXp XP · ${AppStrings.gamificationRank} #$myRank',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              LinearPercentIndicator(
                lineHeight: 8,
                percent: game.levelProgressPercent(user.xp).clamp(0.0, 1.0),
                backgroundColor: AppColors.surface.withValues(alpha: 0.2),
                progressColor: AppColors.accent,
                barRadius: const Radius.circular(8),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 6),
              Text(
                '${AppStrings.levelLabel} ${user.level} · '
                '${game.xpProgressInLevel(user.xp)}/${GamificationService.xpPerLevel} XP',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.gamificationLeaderboard,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ...board.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: e.isMe ? AppColors.accentSoft : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: e.isMe ? AppColors.accent : AppColors.surfaceAlt,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#${e.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: e.rank <= 3 ? AppColors.accentDark : null,
                    ),
                  ),
                ),
                Text(e.avatarEmoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.isMe ? '${e.nameUz} (${AppStrings.gamificationYou})' : e.nameUz,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              e.isMe ? FontWeight.w900 : FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  '${e.weeklyXp} XP',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
