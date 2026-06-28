import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../domain/models/budget_category.dart';
import '../../../domain/models/financial_movement.dart';

class CategoryGrid extends StatelessWidget {
  final MovementType movementType;
  final List<BudgetCategory> categories;
  final BudgetCategory? selected;
  final ValueChanged<BudgetCategory> onSelected;

  const CategoryGrid({
    super.key,
    required this.movementType,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  Color get _activeColor => movementType == MovementType.ingreso
      ? AppColors.accent
      : AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoría', style: AppTypography.label()),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final cat = categories[i];
            final isSelected = selected?.id == cat.id;
            return _CategoryCell(
              category: cat,
              isSelected: isSelected,
              activeColor: _activeColor,
              onTap: () => onSelected(cat),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final BudgetCategory category;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _CategoryCell({
    required this.category,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: AppTypography.micro(
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
