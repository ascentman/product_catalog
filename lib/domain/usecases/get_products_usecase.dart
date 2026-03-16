import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository _repository;

  const GetProductsUseCase(this._repository);

  Future<ProductsResult> call({int skip = 0, int limit = 20}) {
    return _repository.getProducts(skip: skip, limit: limit);
  }
}
