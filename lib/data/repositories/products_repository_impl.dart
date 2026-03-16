import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/local/products_local_datasource.dart';
import '../datasources/remote/products_remote_datasource.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;
  final ProductsLocalDataSource _localDataSource;
  final Connectivity _connectivity;

  const ProductsRepositoryImpl({
    required ProductsRemoteDataSource remoteDataSource,
    required ProductsLocalDataSource localDataSource,
    required Connectivity connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<ProductsResult> getProducts({int skip = 0, int limit = 20}) async {
    final cachedResult = await _localDataSource.getCachedProducts(
      skip: skip,
      limit: limit,
    );

    if (cachedResult is CacheHit<ProductsListResponse>) {
      AppLogger.info('Serving products from cache (skip=$skip)', tag: 'Repo');
      final r = cachedResult.data;
      return ProductsResult(
        products: r.products.map((m) => m.toEntity()).toList(),
        total: r.total,
        isFromCache: true,
      );
    }

    final online = await _isOnline();
    if (!online) {
      throw const NetworkException('No internet connection and no cache available');
    }

    try {
      final response = await _remoteDataSource.getProducts(skip: skip, limit: limit);
      await _localDataSource.cacheProducts(response: response, skip: skip, limit: limit);
      return ProductsResult(
        products: response.products.map((m) => m.toEntity()).toList(),
        total: response.total,
        isFromCache: false,
      );
    } catch (e) {
      AppLogger.error('getProducts network failed', error: e, tag: 'Repo');
      rethrow;
    }
  }

  @override
  Future<ProductsResult> searchProducts({
    required String query,
    int skip = 0,
    int limit = 20,
  }) async {
    final cached = await _localDataSource.getCachedSearchResults(query: query);
    if (cached is CacheHit<ProductsListResponse>) {
      AppLogger.info('Serving search "$query" from cache', tag: 'Repo');
      final r = cached.data;
      return ProductsResult(
        products: r.products.map((m) => m.toEntity()).toList(),
        total: r.total,
        isFromCache: true,
      );
    }

    final online = await _isOnline();
    if (!online) {
      throw const NetworkException('No internet connection');
    }

    final response = await _remoteDataSource.searchProducts(
      query: query,
      skip: skip,
      limit: limit,
    );
    await _localDataSource.cacheSearchResults(response: response, query: query);
    return ProductsResult(
      products: response.products.map((m) => m.toEntity()).toList(),
      total: response.total,
      isFromCache: false,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    final cached = await _localDataSource.getCachedCategories();
    if (cached is CacheHit<List<CategoryModel>>) {
      AppLogger.info('Serving categories from cache', tag: 'Repo');
      return cached.data.map((c) => c.slug).toList();
    }

    final online = await _isOnline();
    if (!online) {
      throw const NetworkException('No internet connection');
    }

    final categories = await _remoteDataSource.getCategories();
    await _localDataSource.cacheCategories(categories);
    return categories.map((c) => c.slug).toList();
  }

  @override
  Future<ProductsResult> getProductsByCategory({
    required String category,
    int skip = 0,
    int limit = 20,
  }) async {
    final cached = await _localDataSource.getCachedSearchResults(
      query: '',
      category: category,
    );
    if (cached is CacheHit<ProductsListResponse>) {
      AppLogger.info('Serving category "$category" from cache', tag: 'Repo');
      final r = cached.data;
      return ProductsResult(
        products: r.products.map((m) => m.toEntity()).toList(),
        total: r.total,
        isFromCache: true,
      );
    }

    final online = await _isOnline();
    if (!online) {
      throw const NetworkException('No internet connection');
    }

    final response = await _remoteDataSource.getProductsByCategory(
      category: category,
      skip: skip,
      limit: limit,
    );
    await _localDataSource.cacheSearchResults(
      response: response,
      query: '',
      category: category,
    );
    return ProductsResult(
      products: response.products.map((m) => m.toEntity()).toList(),
      total: response.total,
      isFromCache: false,
    );
  }

  @override
  Future<Product> getProductById(int id) async {
    final cached = await _localDataSource.getCachedProduct(id);
    if (cached is CacheHit<ProductModel>) {
      AppLogger.info('Serving product $id from cache', tag: 'Repo');
      return cached.data.toEntity();
    }

    final online = await _isOnline();
    if (!online) {
      throw const NetworkException('No internet connection');
    }

    final model = await _remoteDataSource.getProductById(id);
    await _localDataSource.cacheProduct(model);
    return model.toEntity();
  }
}
