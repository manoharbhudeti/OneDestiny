import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final unselectedBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final selectedBg = isDark
        ? primaryColor.withValues(alpha: 0.25)
        : primaryColor.withValues(alpha: 0.12);

    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final selectedBorder = AppColors.accentGold;

    final iconColor = isSelected
        ? primaryColor
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    final textColor = isSelected
        ? primaryColor
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.05 : 1.0,
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : unselectedBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? selectedBorder : unselectedBorder,
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.accentGold.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                category.icon,
                size: 26,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.description(
                context,
                customColor: textColor,
              ).copyWith(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
