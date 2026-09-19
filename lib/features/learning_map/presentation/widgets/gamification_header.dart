import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../features/gamification/domain/avatar_catalog.dart';
import '../../../../models/user_model.dart';
import '../../../../services/gamification_service.dart';

/// Streak, tanga, XP/daraja va avatar paneli.
class GamificationHeader extends StatelessWidget {
  const GamificationHeader({
    super.key,
    required this.user,
    this.onTap,
  });

  final UserModel user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final game = GamificationService();
    final avatar = AvatarCatalog.byId(user.avatarId);
    final progress = game.levelProgressPercent(user.xp).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      avatar.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.studentName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                        ),
                        Text(
                          '${AppStrings.levelLabel} ${user.level} · ${user.grade.labelUz}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textOnPrimary
                                    .withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                  _StatChip(icon: '🔥', value: '${user.streakDays}'),
                  const SizedBox(width: 8),
                  _StatChip(icon: '🪙', value: '${user.coins}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      lineHeight: 8,
                      percent: progress,
                      backgroundColor:
                          AppColors.surface.withValues(alpha: 0.2),
                      progressColor: AppColors.accent,
                      barRadius: const Radius.circular(8),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${game.xpProgressInLevel(user.xp)}/${GamificationService.xpPerLevel}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.value});

  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
