import 'product.dart';

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
