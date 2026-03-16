import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../../data/datasources/local/products_local_datasource.dart';
import '../../data/datasources/remote/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../features/product_detail/cubit/product_detail_cubit.dart';
import '../../features/product_list/cubit/product_list_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Dio>(() => DioClient.createDio());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Hive boxes
  final cacheBox = await Hive.openBox<String>(AppConstants.cacheBoxName);
  final metaBox = await Hive.openBox<String>(AppConstants.cacheMetaBoxName);
  sl.registerSingleton<Box<String>>(cacheBox, instanceName: 'cacheBox');
  sl.registerSingleton<Box<String>>(metaBox, instanceName: 'metaBox');

  // Data sources
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<ProductsLocalDataSource>(
    () => ProductsLocalDataSourceImpl(
      cacheBox: sl<Box<String>>(instanceName: 'cacheBox'),
      metaBox: sl<Box<String>>(instanceName: 'metaBox'),
    ),
  );

  // Repository
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      remoteDataSource: sl<ProductsRemoteDataSource>(),
      localDataSource: sl<ProductsLocalDataSource>(),
      connectivity: sl<Connectivity>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(
    () => GetProductsByCategoryUseCase(sl<ProductsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetProductDetailUseCase(sl<ProductsRepository>()),
  );

  // Cubits (factory so new instance per creation)
  sl.registerFactory(
    () => ProductListCubit(
      getProducts: sl<GetProductsUseCase>(),
      searchProducts: sl<SearchProductsUseCase>(),
      getCategories: sl<GetCategoriesUseCase>(),
      getProductsByCategory: sl<GetProductsByCategoryUseCase>(),
    ),
  );

  sl.registerFactory(
    () => ProductDetailCubit(
      getProductDetail: sl<GetProductDetailUseCase>(),
    ),
  );
}
