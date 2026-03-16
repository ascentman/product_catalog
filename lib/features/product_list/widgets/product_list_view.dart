import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../design_system/components/product_card.dart';
import '../../../design_system/theme/app_spacing.dart';
import '../../../domain/entities/product.dart';

class ProductListView extends StatefulWidget {
  final List<Product> products;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final ValueChanged<Product> onProductTap;
  final ScrollController? scrollController;

  const ProductListView({
    super.key,
    required this.products,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onProductTap,
    this.scrollController,
  });

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late ScrollController _scrollController;

  // Index from which new items should animate; items below are already visible.
  int _animatedFromIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scrollController.addListener(_onScroll);
    _animatedFromIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void didUpdateWidget(ProductListView old) {
    super.didUpdateWidget(old);

    final prev = old.products.length;
    final curr = widget.products.length;

    if (curr == 0) {
      _animatedFromIndex = 0;
      _animController.reset();
      return;
    }

    if (curr < prev ||
        (curr > 0 &&
            prev > 0 &&
            widget.products.first.id != old.products.first.id)) {
      // Full replacement (refresh / search / category change).
      _animatedFromIndex = 0;
      _animController.reset();
      _animController.forward();
      return;
    }

    if (curr > prev) {
      // Pagination append — animate only newly added tail.
      _animatedFromIndex = prev;
      _animController.reset();
      _animController.forward();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    return CustomScrollView(
      key: const PageStorageKey('product_list'),
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];

              // Items already on screen are rendered statically.
              if (index < _animatedFromIndex) {
                return ProductCard(
                  product: product,
                  onTap: () => widget.onProductTap(product),
                );
              }

              // Stagger the animation window.
              final localIndex = index - _animatedFromIndex;
              final delay = (localIndex * 0.06).clamp(0.0, 0.8);
              final end = (delay + 0.35).clamp(0.0, 1.0);
              final animation = CurvedAnimation(
                parent: _animController,
                curve: Interval(delay, end, curve: Curves.easeOut),
              );

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: ProductCard(
                  product: product,
                  onTap: () => widget.onProductTap(product),
                ),
              );
            },
          ),
        ),
        if (widget.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (!widget.hasMore && widget.products.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  'All products loaded',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    return 2;
  }
}
