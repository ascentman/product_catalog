import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/get_product_detail_usecase.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductDetailUseCase _getProductDetail;

  ProductDetailCubit({
    required GetProductDetailUseCase getProductDetail,
  })  : _getProductDetail = getProductDetail,
        super(const ProductDetailState());

  Future<void> loadProduct(int id) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));

    try {
      final product = await _getProductDetail(id);
      emit(state.copyWith(
        status: ProductDetailStatus.loaded,
        product: product,
      ));
    } catch (e) {
      AppLogger.error('loadProduct($id) failed', error: e, tag: 'ProductDetailCubit');
      emit(state.copyWith(
        status: ProductDetailStatus.error,
        errorMessage: _errorMessage(e),
      ));
    }
  }

  Future<void> retry(int id) async {
    await loadProduct(id);
  }

  String _errorMessage(Object e) {
    final str = e.toString();
    if (str.contains('No internet')) return 'No internet connection.';
    if (str.contains('not found') || str.contains('404')) return 'Product not found.';
    return 'Failed to load product details.';
  }
}
