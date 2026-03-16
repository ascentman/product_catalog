import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductListCubit>()..loadProducts(),
      child: AdaptiveLayout(
        phoneLayout: (context) => _PhoneLayout(
          onProductSelected: (product) => context.push(AppRoute.productDetail.location(product.id)),
        ),
        tabletLayout: (context) => const _TabletLayout(),
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
            onPressed: () => context.push(AppRoute.showcase.location()),
          ),
          _ThemeToggleButton(),
        ],
      ),
      body: _ProductListBody(onProductSelected: onProductSelected),
    );
  }
}

class _TabletLayout extends StatefulWidget {
  const _TabletLayout();

  @override
  State<_TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<_TabletLayout> {
  static const double _minPanelWidth = 250;
  static const double _maxPanelWidth = 600;
  static const double _defaultPanelWidth = 380;

  double _leftWidth = _defaultPanelWidth;
  int? _selectedProductId;

  void _onDrag(double delta) {
    setState(() {
      _leftWidth = (_leftWidth + delta).clamp(_minPanelWidth, _maxPanelWidth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: 'Component Showcase',
            onPressed: () => context.push(AppRoute.showcase.location()),
          ),
          _ThemeToggleButton(),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: _leftWidth,
            child: _ProductListBody(
              onProductSelected: (product) {
                setState(() => _selectedProductId = product.id);
              },
            ),
          ),
          _PanelDivider(onDrag: _onDrag),
          Expanded(
            child: _selectedProductId != null
                ? ProductDetailScreen(
                    key: ValueKey(_selectedProductId),
                    productId: _selectedProductId!,
                    isEmbedded: true,
                  )
                : const _EmptyDetailPane(),
          ),
        ],
      ),
    );
  }
}

class _PanelDivider extends StatefulWidget {
  final ValueChanged<double> onDrag;

  const _PanelDivider({required this.onDrag});

  @override
  State<_PanelDivider> createState() => _PanelDividerState();
}

class _PanelDividerState extends State<_PanelDivider> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovering
        ? AppColors.primary
        : Theme.of(context).dividerColor;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 8,
          color: color,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _hovering ? 4 : 1,
              height: 48,
              decoration: BoxDecoration(
                color: _hovering ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
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
              child: _ProductListContent(
                state: state,
                cubit: cubit,
                onProductSelected: onProductSelected,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductListContent extends StatelessWidget {
  final ProductListState state;
  final ProductListCubit cubit;
  final ValueChanged<Product> onProductSelected;

  const _ProductListContent({
    required this.state,
    required this.cubit,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
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
