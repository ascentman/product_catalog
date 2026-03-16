import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/di/theme_cubit.dart';
import '../../../design_system/components/empty_state.dart';
import '../../../design_system/components/error_state.dart';
import '../../../design_system/components/search_bar.dart';
import '../../../design_system/components/skeleton_loader.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/theme/app_spacing.dart';
import '../../../domain/entities/product.dart';
import '../../product_detail/screens/product_detail_screen.dart';
import '../../responsive/adaptive_layout.dart';
import '../cubit/product_list_cubit.dart';
import '../cubit/product_list_state.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_list_view.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductListCubit>()..loadProducts(),
      child: AdaptiveLayout(
        phoneLayout: (context) => _PhoneLayout(
          onProductSelected: (product) => context.push('/products/${product.id}'),
        ),
        tabletLayout: (context) => _TabletLayout(
          selectedProductId: _selectedProductId,
          onProductSelected: (product) {
            setState(() => _selectedProductId = product.id);
          },
        ),
      ),
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  final ValueChanged<Product> onProductSelected;

  const _PhoneLayout({required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: 'Component Showcase',
            onPressed: () => context.push('/showcase'),
          ),
          _ThemeToggleButton(),
        ],
      ),
      body: _ProductListBody(onProductSelected: onProductSelected),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final int? selectedProductId;
  final ValueChanged<Product> onProductSelected;

  const _TabletLayout({
    required this.selectedProductId,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: 'Component Showcase',
            onPressed: () => context.push('/showcase'),
          ),
          _ThemeToggleButton(),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 380,
            child: _ProductListBody(
              onProductSelected: onProductSelected,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedProductId != null
                ? ProductDetailScreen(
                    productId: selectedProductId!,
                    isEmbedded: true,
                  )
                : const _EmptyDetailPane(),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetailPane extends StatelessWidget {
  const _EmptyDetailPane();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Select a product to view details',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProductListBody extends StatelessWidget {
  final ValueChanged<Product> onProductSelected;

  const _ProductListBody({required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListCubit, ProductListState>(
      builder: (context, state) {
        final cubit = context.read<ProductListCubit>();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: AppSearchBar(
                onChanged: cubit.search,
              ),
            ),
            if (cubit.categories.isNotEmpty)
              CategoryFilterBar(
                categories: cubit.categories,
                selectedCategory: state.selectedCategory,
                onCategorySelected: cubit.selectCategory,
              ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _buildContent(context, state, cubit),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductListState state,
    ProductListCubit cubit,
  ) {
    switch (state.status) {
      case ProductListStatus.initial:
      case ProductListStatus.loading:
        return const SkeletonGrid(count: 6);

      case ProductListStatus.error:
        return ErrorState(
          message: 'Failed to load products',
          details: state.errorMessage,
          onRetry: cubit.retry,
        );

      case ProductListStatus.empty:
        return EmptyState(
          title: 'No products found',
          subtitle: state.currentQuery.isNotEmpty
              ? 'Try a different search term'
              : 'No products available in this category',
          icon: Icons.search_off_rounded,
          actionLabel: state.currentQuery.isNotEmpty ? 'Clear search' : null,
          onAction: state.currentQuery.isNotEmpty
              ? () => cubit.search('')
              : null,
        );

      case ProductListStatus.loaded:
      case ProductListStatus.loadingMore:
        return _BrandedRefreshIndicator(
          onRefresh: () => cubit.loadProducts(refresh: true),
          child: ProductListView(
            products: state.products,
            hasMore: state.hasMore,
            isLoadingMore: state.status == ProductListStatus.loadingMore,
            onLoadMore: cubit.loadMore,
            onProductTap: onProductSelected,
          ),
        );
    }
  }
}

/// Custom pull-to-refresh wrapper.
/// Shows a branded circular indicator that scales in as the user pulls,
/// then spins while the refresh future is running.
class _BrandedRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _BrandedRefreshIndicator({
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      // Branded colors.
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      // A slightly larger displacement gives the indicator more room to
      // animate before snapping into the "refreshing" position.
      displacement: 60,
      // Stroke width thinner than default for a more refined look.
      strokeWidth: 2.0,
      // Trigger only after the user has pulled past the displacement value.
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}


class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          tooltip: 'Toggle theme',
          onPressed: () => context.read<ThemeCubit>().toggle(),
        );
      },
    );
  }
}
