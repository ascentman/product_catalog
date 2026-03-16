import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'star_rating.dart';
import 'app_badge.dart';
import 'skeleton_loader.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            _buildContent(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'product-image-${product.id}',
          // Maintain the card's top border radius during the Hero flight.
          flightShuttleBuilder: (_, animation, direction, fromCtx, toCtx) {
            final radius = Tween<double>(
              begin: direction == HeroFlightDirection.push ? 12.0 : 0.0,
              end: direction == HeroFlightDirection.push ? 0.0 : 12.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
            return AnimatedBuilder(
              animation: radius,
              builder: (_, child) => ClipRRect(
                borderRadius: BorderRadius.circular(radius.value),
                child: child,
              ),
              child: toCtx.widget,
            );
          },
          child: SizedBox(
            height: AppSpacing.productCardImageHeight,
            width: double.infinity,
            child: product.thumbnail.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ProductCardImageSkeleton(),
                    errorWidget: (_, __, ___) => _buildImagePlaceholder(context),
                  )
                : _buildImagePlaceholder(context),
          ),
        ),
        if (product.hasDiscount)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: AppBadge.discount(product.discountPercentage),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              product.brand,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                StarRating(rating: product.rating, size: 12),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildPricing(isDark),
          ],
        ),
    );
  }

  Widget _buildPricing(bool isDark) {
    if (product.price == null || product.price! < 0) {
      return Text(
        'Price unavailable',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.displayPrice,
          style: AppTextStyles.price.copyWith(color: AppColors.primary),
        ),
        if (product.hasDiscount)
          Text(
            product.originalPrice,
            style: AppTextStyles.priceStrikethrough.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
