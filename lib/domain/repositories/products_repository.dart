import '../entities/product.dart';
import '../entities/products_result.dart';
export '../entities/products_result.dart';

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
