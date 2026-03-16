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
            return _buildLoading(context);
          case ProductDetailStatus.error:
            return _buildError(context, state);
          case ProductDetailStatus.loaded:
            return _buildContent(context, state);
        }
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final content = const Center(child: CircularProgressIndicator());
    if (isEmbedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: content,
    );
  }

  Widget _buildError(BuildContext context, ProductDetailState state) {
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

  Widget _buildContent(BuildContext context, ProductDetailState state) {
    final product = state.product!;
    final heroTag = 'product-image-${product.id}';

    final body = CustomScrollView(
      slivers: [
        if (!isEmbedded)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageGallery(
                images: product.images.isNotEmpty ? product.images : [product.thumbnail],
                heroTag: heroTag,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: ImageGallery(
              images: product.images.isNotEmpty ? product.images : [product.thumbnail],
              heroTag: heroTag,
            ),
          ),
        SliverToBoxAdapter(
          child: ProductInfoSection(product: product),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
      ],
    );

    if (isEmbedded) {
      return body;
    }

    return Scaffold(body: body);
  }
}
