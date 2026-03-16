import '../repositories/products_repository.dart';

class GetCategoriesUseCase {
  final ProductsRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<List<String>> call() {
    return _repository.getCategories();
  }
}
