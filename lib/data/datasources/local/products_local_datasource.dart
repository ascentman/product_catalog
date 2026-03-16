import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../remote/products_remote_datasource.dart';

sealed class CachedData<T> {
  const CachedData();
}

class CacheHit<T> extends CachedData<T> {
  final T data;
  final bool isFromCache;
  const CacheHit({required this.data, this.isFromCache = true});
}

class CacheMiss<T> extends CachedData<T> {
  const CacheMiss();
}

abstract interface class ProductsLocalDataSource {
  Future<CachedData<ProductsListResponse>> getCachedProducts({
    int skip = 0,
    int limit = 20,
  });
  Future<void> cacheProducts({
    required ProductsListResponse response,
    int skip = 0,
    int limit = 20,
  });
  Future<CachedData<List<CategoryModel>>> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<CachedData<ProductModel>> getCachedProduct(int id);
  Future<void> cacheProduct(ProductModel product);
  Future<CachedData<ProductsListResponse>> getCachedSearchResults({
    required String query,
    String? category,
  });
  Future<void> cacheSearchResults({
    required ProductsListResponse response,
    required String query,
    String? category,
  });
  Future<void> clearAll();
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final Box<String> _cacheBox;
  final Box<String> _metaBox;

  const ProductsLocalDataSourceImpl({
    required Box<String> cacheBox,
    required Box<String> metaBox,
  })  : _cacheBox = cacheBox,
        _metaBox = metaBox;

  String _productsKey(int skip, int limit) => 'products_page_${skip}_$limit';
  String _categoriesKey() => 'categories';
  String _productKey(int id) => 'product_$id';
  String _searchKey(String query, String? category) =>
      'search_${query}_${category ?? ''}';
  String _metaKey(String key) => 'meta_$key';

  bool _isExpired(String key) {
    final metaKey = _metaKey(key);
    final raw = _metaBox.get(metaKey);
    if (raw == null) return true;
    try {
      final timestamp = int.parse(raw);
      final stored = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expiryDuration = Duration(hours: AppConstants.cacheExpiryHours);
      return DateTime.now().difference(stored) > expiryDuration;
    } catch (_) {
      return true;
    }
  }

  Future<void> _setTimestamp(String key) async {
    await _metaBox.put(
      _metaKey(key),
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<CachedData<ProductsListResponse>> getCachedProducts({
    int skip = 0,
    int limit = 20,
  }) async {
    final key = _productsKey(skip, limit);
    if (_isExpired(key)) return const CacheMiss();

    final raw = _cacheBox.get(key);
    if (raw == null) return const CacheMiss();

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final products = (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return CacheHit(
        data: ProductsListResponse(
          products: products,
          total: (json['total'] as num).toInt(),
          skip: skip,
          limit: limit,
        ),
      );
    } catch (e) {
      AppLogger.error('getCachedProducts parse error', error: e, tag: 'LocalDS');
      return const CacheMiss();
    }
  }

  @override
  Future<void> cacheProducts({
    required ProductsListResponse response,
    int skip = 0,
    int limit = 20,
  }) async {
    final key = _productsKey(skip, limit);
    final json = jsonEncode({
      'products': response.products.map((p) => p.toJson()).toList(),
      'total': response.total,
    });
    await _cacheBox.put(key, json);
    await _setTimestamp(key);
  }

  @override
  Future<CachedData<List<CategoryModel>>> getCachedCategories() async {
    final key = _categoriesKey();
    if (_isExpired(key)) return const CacheMiss();

    final raw = _cacheBox.get(key);
    if (raw == null) return const CacheMiss();

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final categories = list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return CacheHit(data: categories);
    } catch (e) {
      AppLogger.error('getCachedCategories parse error', error: e, tag: 'LocalDS');
      return const CacheMiss();
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final key = _categoriesKey();
    final json = jsonEncode(categories.map((c) => c.toJson()).toList());
    await _cacheBox.put(key, json);
    await _setTimestamp(key);
  }

  @override
  Future<CachedData<ProductModel>> getCachedProduct(int id) async {
    final key = _productKey(id);
    if (_isExpired(key)) return const CacheMiss();

    final raw = _cacheBox.get(key);
    if (raw == null) return const CacheMiss();

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CacheHit(data: ProductModel.fromJson(json));
    } catch (e) {
      AppLogger.error('getCachedProduct($id) parse error', error: e, tag: 'LocalDS');
      return const CacheMiss();
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    final key = _productKey(product.id);
    await _cacheBox.put(key, jsonEncode(product.toJson()));
    await _setTimestamp(key);
  }

  @override
  Future<CachedData<ProductsListResponse>> getCachedSearchResults({
    required String query,
    String? category,
  }) async {
    final key = _searchKey(query, category);
    if (_isExpired(key)) return const CacheMiss();

    final raw = _cacheBox.get(key);
    if (raw == null) return const CacheMiss();

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final products = (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return CacheHit(
        data: ProductsListResponse(
          products: products,
          total: (json['total'] as num).toInt(),
          skip: 0,
          limit: products.length,
        ),
      );
    } catch (e) {
      AppLogger.error('getCachedSearchResults parse error', error: e, tag: 'LocalDS');
      return const CacheMiss();
    }
  }

  @override
  Future<void> cacheSearchResults({
    required ProductsListResponse response,
    required String query,
    String? category,
  }) async {
    final key = _searchKey(query, category);
    final json = jsonEncode({
      'products': response.products.map((p) => p.toJson()).toList(),
      'total': response.total,
    });
    await _cacheBox.put(key, json);
    await _setTimestamp(key);
  }

  @override
  Future<void> clearAll() async {
    await _cacheBox.clear();
    await _metaBox.clear();
  }
}
