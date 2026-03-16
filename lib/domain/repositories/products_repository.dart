import '../entities/product.dart';

abstract interface class ProductsRepository {
  Future<ProductsResult> getProducts({
    int skip = 0,
    int limit = 20,
  });

  Future<ProductsResult> searchProducts({
    required String query,
    int skip = 0,
    int limit = 20,
  });

  Future<List<String>> getCategories();

  Future<ProductsResult> getProductsByCategory({
    required String category,
    int skip = 0,
    int limit = 20,
  });

  Future<Product> getProductById(int id);
}

class ProductsResult {
  final List<Product> products;
  final int total;
  final bool isFromCache;

  const ProductsResult({
    required this.products,
    required this.total,
    this.isFromCache = false,
  });
}
