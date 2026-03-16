import 'package:flutter/material.dart';
import '../../../design_system/components/app_badge.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/category_chip.dart';
import '../../../design_system/components/empty_state.dart';
import '../../../design_system/components/error_state.dart';
import '../../../design_system/components/product_card.dart';
import '../../../design_system/components/skeleton_loader.dart';
import '../../../design_system/components/star_rating.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/theme/app_spacing.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/theme/app_theme.dart';
import '../../../domain/entities/product.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  bool _isDark = false;
  String? _selectedChip = 'electronics';

  static final Product _sampleProduct = Product(
    id: 1,
    title: 'Wireless Headphones Pro',
    description: 'High quality wireless headphones with noise cancellation.',
    price: 129.99,
    discountPercentage: 15.5,
    rating: 4.3,
    stock: 42,
    brand: 'AudioBrand',
    category: 'electronics',
    thumbnail: 'https://cdn.dummyjson.com/product-images/1/thumbnail.jpg',
    images: ['https://cdn.dummyjson.com/product-images/1/1.jpg'],
  );

  @override
  Widget build(BuildContext context) {
    final theme = _isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          title: const Text('Component Showcase'),
          actions: [
            Row(
              children: [
                Icon(
                  _isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.appBarTheme.foregroundColor,
                ),
                Switch(
                  value: _isDark,
                  onChanged: (v) => setState(() => _isDark = v),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _SectionHeader(title: 'Buttons', theme: theme),
            _ButtonsSection(theme: theme),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Product Cards', theme: theme),
            _ProductCardsSection(theme: theme, sampleProduct: _sampleProduct),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Category Chips', theme: theme),
            _CategoryChipsSection(
              theme: theme,
              selectedChip: _selectedChip,
              onChipSelected: (slug) => setState(() => _selectedChip = slug),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Star Ratings', theme: theme),
            _StarRatingsSection(theme: theme),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Badges', theme: theme),
            _BadgesSection(theme: theme),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Skeleton Loader', theme: theme),
            _SkeletonSection(theme: theme),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Error State', theme: theme),
            _ErrorSection(theme: theme),
            const SizedBox(height: AppSpacing.xxl),

            _SectionHeader(title: 'Empty State', theme: theme),
            _EmptySection(theme: theme),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  final ThemeData theme;

  const _ButtonsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          const AppButton.primary(label: 'Primary Button'),
          const AppButton.secondary(label: 'Secondary Button'),
          const AppButton.text(label: 'Text Button'),
          AppButton.primary(
            label: 'With Icon',
            leadingIcon: Icons.add,
            onPressed: () {},
          ),
          const AppButton.primary(label: 'Loading', isLoading: true),
          const AppButton.primary(label: 'Disabled'),
        ],
      ),
    );
  }
}

class _ProductCardsSection extends StatelessWidget {
  final ThemeData theme;
  final Product sampleProduct;

  const _ProductCardsSection({required this.theme, required this.sampleProduct});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ProductCard(
              product: sampleProduct,
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: ProductCardSkeleton()),
        ],
      ),
    );
  }
}

class _CategoryChipsSection extends StatelessWidget {
  final ThemeData theme;
  final String? selectedChip;
  final ValueChanged<String?> onChipSelected;

  const _CategoryChipsSection({
    required this.theme,
    required this.selectedChip,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    const chips = ['All', 'Electronics', 'Clothing', 'Accessories', 'Furniture'];
    return Theme(
      data: theme,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: chips.map((chip) {
          final slug = chip.toLowerCase();
          return CategoryChip(
            label: chip,
            isSelected: selectedChip == slug,
            onTap: () => onChipSelected(slug),
          );
        }).toList(),
      ),
    );
  }
}

class _StarRatingsSection extends StatelessWidget {
  final ThemeData theme;

  const _StarRatingsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    final ratings = [5.0, 4.5, 4.0, 3.5, 2.0, 1.0, 0.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ratings
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  StarRating(rating: r, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    r.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  final ThemeData theme;

  const _BadgesSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppBadge.discount(15.5),
        AppBadge.discount(5.0),
        AppBadge.discount(50.0),
        AppBadge.inStock(10),
        AppBadge.inStock(0),
        const AppBadge(label: 'New', variant: BadgeVariant.custom, customColor: AppColors.primary),
        const AppBadge(label: 'Sale', variant: BadgeVariant.custom, customColor: AppColors.secondary),
      ],
    );
  }
}

class _SkeletonSection extends StatelessWidget {
  final ThemeData theme;

  const _SkeletonSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ProductCardSkeleton()),
          SizedBox(width: AppSpacing.md),
          Expanded(child: ProductCardSkeleton()),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final ThemeData theme;

  const _ErrorSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: ErrorState(
          message: 'Failed to load products',
          details: 'NetworkException: No internet connection',
          onRetry: () {},
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final ThemeData theme;

  const _EmptySection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: EmptyState(
          title: 'No products found',
          subtitle: 'Try a different search term or category',
          icon: Icons.search_off_rounded,
          actionLabel: 'Clear filters',
          onAction: () {},
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Divider(color: theme.dividerColor),
        ],
      ),
    );
  }
}
