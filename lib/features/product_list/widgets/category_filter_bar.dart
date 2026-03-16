import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_system/components/category_chip.dart';
import '../../../design_system/theme/app_spacing.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  String _displayName(String slug) {
    return slug
        .split('-')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = [null, ...categories];

    return SizedBox(
      height: AppSpacing.categoryBarHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = category == selectedCategory;
          final label = category == null
              ? AppConstants.allCategoriesLabel
              : _displayName(category);

          return Center(
            child: CategoryChip(
              label: label,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}
