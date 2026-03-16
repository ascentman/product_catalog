import 'package:flutter/material.dart';
import '../../../design_system/components/app_badge.dart';
import '../../../design_system/components/star_rating.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/theme/app_spacing.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: AppTextStyles.headlineSmall.copyWith(color: textColor),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge.inStock(product.stock),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.brand,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              StarRating(rating: product.rating, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${product.rating.toStringAsFixed(1)} / 5.0',
                style: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '(${product.stock} in stock)',
                style: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          _buildPricing(isDark, textColor, secondaryColor),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Description',
            style: AppTextStyles.titleMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.description,
            style: AppTextStyles.bodyMedium.copyWith(color: secondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDetails(isDark, textColor, secondaryColor),
        ],
      ),
    );
  }

  Widget _buildPricing(bool isDark, Color textColor, Color secondaryColor) {
    if (product.price == null || product.price! < 0) {
      return Text(
        'Price unavailable',
        style: AppTextStyles.titleLarge.copyWith(
          color: secondaryColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          product.displayPrice,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.originalPrice,
                style: AppTextStyles.priceStrikethrough.copyWith(
                  color: secondaryColor,
                  fontSize: 16,
                ),
              ),
              AppBadge.discount(product.discountPercentage),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetails(bool isDark, Color textColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: AppTextStyles.titleMedium.copyWith(color: textColor),
        ),
        const SizedBox(height: AppSpacing.md),
        _DetailRow(label: 'Category', value: product.category, isDark: isDark),
        _DetailRow(label: 'Brand', value: product.brand, isDark: isDark),
        _DetailRow(
          label: 'Stock',
          value: product.stock > 0 ? '${product.stock} units' : 'Out of stock',
          isDark: isDark,
        ),
        _DetailRow(
          label: 'Rating',
          value: '${product.rating.toStringAsFixed(1)} / 5.0',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
