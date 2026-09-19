import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/lesson_model.dart';
import '../../../../models/study_plan_model.dart';

/// Bitta roadmap tugmasi: faol / qulflangan / yakunlangan.
class RoadmapNode extends StatelessWidget {
  const RoadmapNode({
    super.key,
    required this.lesson,
    required this.status,
    required this.onTap,
  });

  final LessonModel lesson;
  final RoadmapNodeStatus status;
  final VoidCallback onTap;

  Color get _ringColor => switch (status) {
        RoadmapNodeStatus.completed => AppColors.nodeCompleted,
        RoadmapNodeStatus.active => AppColors.nodeActive,
        RoadmapNodeStatus.locked => AppColors.nodeLocked,
      };

  IconData get _icon {
    if (lesson.isExam && status != RoadmapNodeStatus.locked) {
      return Icons.quiz_rounded;
    }
    return switch (status) {
      RoadmapNodeStatus.completed => Icons.check_rounded,
      RoadmapNodeStatus.active => Icons.play_arrow_rounded,
      RoadmapNodeStatus.locked => Icons.lock_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isActive = status == RoadmapNodeStatus.active;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: isActive ? 84 : 72,
              height: isActive ? 84 : 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: status == RoadmapNodeStatus.active
                    ? AppColors.goldGradient
                    : null,
                color: status == RoadmapNodeStatus.active
                    ? null
                    : _ringColor.withValues(alpha: 0.15),
                border: Border.all(color: _ringColor, width: 4),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.45),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _icon,
                size: isActive ? 40 : 32,
                color: status == RoadmapNodeStatus.active
                    ? AppColors.textPrimary
                    : _ringColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lesson.titleUz,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: status == RoadmapNodeStatus.locked
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppStrings.weekPrefix} ${lesson.weekNumber} · ${lesson.topic}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
            ),
            if (status == RoadmapNodeStatus.completed ||
                (status == RoadmapNodeStatus.active &&
                    lesson.masteryPercent > 0)) ...[
              const SizedBox(height: 6),
              Text(
                '${lesson.masteryPercent.toStringAsFixed(0)}${AppStrings.percent}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _ringColor,
                      fontSize: 13,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ikki tugma orasidagi vertikal chiziq.
class RoadmapConnector extends StatelessWidget {
  const RoadmapConnector({super.key, required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: completed ? AppColors.success : AppColors.nodeLocked,
      ),
    );
  }
}
