import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';

/// 3-sinf / 4-sinf tanlash kartalari.
class GradeSelector extends StatelessWidget {
  const GradeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StudentGrade selected;
  final ValueChanged<StudentGrade> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GradeCard(
            grade: StudentGrade.grade3,
            selected: selected == StudentGrade.grade3,
            onTap: () => onChanged(StudentGrade.grade3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GradeCard(
            grade: StudentGrade.grade4,
            selected: selected == StudentGrade.grade4,
            onTap: () => onChanged(StudentGrade.grade4),
          ),
        ),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.grade,
    required this.selected,
    required this.onTap,
  });

  final StudentGrade grade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.surfaceAlt,
            width: selected ? 3 : 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              '${grade.number}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    color: selected ? AppColors.accentDark : AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              grade.labelUz,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected
                        ? AppColors.accentDark
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
