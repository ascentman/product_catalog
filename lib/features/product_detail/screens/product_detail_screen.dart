import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../design_system/components/error_state.dart';
import '../../../design_system/theme/app_spacing.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/product_detail_state.dart';
import '../widgets/image_gallery.dart';
import '../widgets/product_info_section.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  final bool isEmbedded;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailCubit>()..loadProduct(productId),
      child: _ProductDetailView(isEmbedded: isEmbedded),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  final bool isEmbedded;

  const _ProductDetailView({required this.isEmbedded});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        switch (state.status) {
          case ProductDetailStatus.initial:
          case ProductDetailStatus.loading:
            return _DetailLoading(isEmbedded: isEmbedded);
          case ProductDetailStatus.error:
            return _DetailError(state: state, isEmbedded: isEmbedded);
          case ProductDetailStatus.loaded:
            return _DetailContent(state: state, isEmbedded: isEmbedded);
        }
      },
    );
  }
}

class _DetailLoading extends StatelessWidget {
  final bool isEmbedded;

  const _DetailLoading({required this.isEmbedded});

  @override
  Widget build(BuildContext context) {
    const content = Center(child: CircularProgressIndicator());
    if (isEmbedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: content,
    );
  }
}

class _DetailError extends StatelessWidget {
  final ProductDetailState state;
  final bool isEmbedded;

  const _DetailError({required this.state, required this.isEmbedded});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductDetailCubit>();
    final content = ErrorState(
      message: 'Failed to load product',
      details: state.errorMessage,
      onRetry: () => cubit.retry(
        context.findAncestorWidgetOfExactType<ProductDetailScreen>()?.productId ?? 0,
      ),
    );
    if (isEmbedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: content,
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ProductDetailState state;
  final bool isEmbedded;

  const _DetailContent({required this.state, required this.isEmbedded});

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    // On tablet the card and detail panel are visible simultaneously,
    // so using the shared hero tag would create a duplicate. Only animate
    // on the phone push transition.
    final heroTag = isEmbedded ? 'product-image-${product.id}-embedded' : 'product-image-${product.id}';

    final gallery = ImageGallery(
      images: product.images.isNotEmpty ? product.images : [product.thumbnail],
      heroTag: heroTag,
    );

    final body = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: gallery),
        SliverToBoxAdapter(child: ProductInfoSection(product: product)),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
      ],
    );

    if (isEmbedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(),
      body: body,
    );
  }
}
