import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductDetailUseCase {
  final ProductsRepository _repository;

  const GetProductDetailUseCase(this._repository);

  Future<Product> call(int id) {
    return _repository.getProductById(id);
  }
}
