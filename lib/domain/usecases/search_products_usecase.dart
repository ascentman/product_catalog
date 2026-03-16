import '../repositories/products_repository.dart';

class SearchProductsUseCase {
  final ProductsRepository _repository;

  const SearchProductsUseCase(this._repository);

  Future<ProductsResult> call({
    required String query,
    int skip = 0,
    int limit = 20,
  }) {
    return _repository.searchProducts(query: query, skip: skip, limit: limit);
  }
}
