import '../repositories/products_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductsRepository _repository;

  const GetProductsByCategoryUseCase(this._repository);

  Future<ProductsResult> call({
    required String category,
    int skip = 0,
    int limit = 20,
  }) {
    return _repository.getProductsByCategory(
      category: category,
      skip: skip,
      limit: limit,
    );
  }
}
