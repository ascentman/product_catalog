class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const String productsEndpoint = '/products';
  static const String searchEndpoint = '/products/search';
  static const String categoriesEndpoint = '/products/categories';

  static const int paginationLimit = 20;
  static const double tabletBreakpoint = 768.0;
  static const int cacheExpiryHours = 1;

  static const String cacheBoxName = 'product_cache';
  static const String cacheMetaBoxName = 'cache_meta';

  static const String allCategoriesLabel = 'All';
  static const String priceUnavailable = 'Price unavailable';

  static const Duration debounceDuration = Duration(milliseconds: 500);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
