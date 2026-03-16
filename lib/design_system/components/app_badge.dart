import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

enum BadgeVariant { discount, inStock, outOfStock, custom }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final Color? customColor;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.custom,
    this.customColor,
  });

  factory AppBadge.discount(double percentage) {
    return AppBadge(
      label: '-${percentage.toStringAsFixed(0)}%',
      variant: BadgeVariant.discount,
    );
  }

  factory AppBadge.inStock(int stock) {
    if (stock <= 0) {
      return const AppBadge(label: 'Out of Stock', variant: BadgeVariant.outOfStock);
    }
    return const AppBadge(label: 'In Stock', variant: BadgeVariant.inStock);
  }

  Color get _backgroundColor {
    switch (variant) {
      case BadgeVariant.discount:
        return AppColors.badgeDiscount;
      case BadgeVariant.inStock:
        return AppColors.badgeInStock;
      case BadgeVariant.outOfStock:
        return AppColors.badgeOutOfStock;
      case BadgeVariant.custom:
        return customColor ?? AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
