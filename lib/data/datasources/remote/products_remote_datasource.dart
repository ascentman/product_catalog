import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

abstract interface class ProductsRemoteDataSource {
  Future<ProductsListResponse> getProducts({int skip = 0, int limit = 20});
  Future<ProductsListResponse> searchProducts({
    required String query,
    int skip = 0,
    int limit = 20,
  });
  Future<List<CategoryModel>> getCategories();
  Future<ProductsListResponse> getProductsByCategory({
    required String category,
    int skip = 0,
    int limit = 20,
  });
  Future<ProductModel> getProductById(int id);
}

class ProductsListResponse {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsListResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio _dio;

  const ProductsRemoteDataSourceImpl(this._dio);

  @override
  Future<ProductsListResponse> getProducts({int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get(
        AppConstants.productsEndpoint,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return _parseListResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('getProducts failed', error: e, tag: 'RemoteDS');
      throw _mapDioException(e);
    }
  }

  @override
  Future<ProductsListResponse> searchProducts({
    required String query,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.searchEndpoint,
        queryParameters: {'q': query, 'skip': skip, 'limit': limit},
      );
      return _parseListResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('searchProducts failed', error: e, tag: 'RemoteDS');
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(AppConstants.categoriesEndpoint);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) {
              if (item is Map<String, dynamic>) {
                return CategoryModel.fromJson(item);
              }
              return CategoryModel(slug: item.toString(), name: item.toString(), url: '');
            })
            .toList();
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error('getCategories failed', error: e, tag: 'RemoteDS');
      throw _mapDioException(e);
    }
  }

  @override
  Future<ProductsListResponse> getProductsByCategory({
    required String category,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.productsEndpoint}/category/$category',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return _parseListResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('getProductsByCategory failed', error: e, tag: 'RemoteDS');
      throw _mapDioException(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('getProductById($id) failed', error: e, tag: 'RemoteDS');
      throw _mapDioException(e);
    }
  }

  ProductsListResponse _parseListResponse(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    return ProductsListResponse(
      products: rawProducts
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );
  }

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException('No internet connection');
    }
    if (e.response?.statusCode == 404) {
      return NotFoundException('Resource not found');
    }
    return ServerException(e.message ?? 'Unknown server error');
  }
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  @override
  String toString() => 'ServerException: $message';
}
