import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/search_products_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/usecases/get_products_by_category_usecase.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  final GetProductsUseCase _getProducts;
  final SearchProductsUseCase _searchProducts;
  final GetCategoriesUseCase _getCategories;
  final GetProductsByCategoryUseCase _getProductsByCategory;
  final Debouncer _debouncer;

  List<String> _categories = [];
  List<String> get categories => _categories;

  ProductListCubit({
    required GetProductsUseCase getProducts,
    required SearchProductsUseCase searchProducts,
    required GetCategoriesUseCase getCategories,
    required GetProductsByCategoryUseCase getProductsByCategory,
    Debouncer? debouncer,
  })  : _getProducts = getProducts,
        _searchProducts = searchProducts,
        _getCategories = getCategories,
        _getProductsByCategory = getProductsByCategory,
        _debouncer = debouncer ?? Debouncer(delay: AppConstants.debounceDuration),
        super(const ProductListState());

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.status == ProductListStatus.loading && !refresh) return;

    emit(state.copyWith(
      status: ProductListStatus.loading,
      products: refresh ? [] : state.products,
      currentPage: 0,
      errorMessage: null,
    ));

    await _fetchCurrentView(skip: 0);
    await _loadCategoriesIfNeeded();
  }

  Future<void> loadMore() async {
    if (state.status == ProductListStatus.loadingMore) return;
    if (!state.hasMore) return;
    if (state.status != ProductListStatus.loaded) return;

    emit(state.copyWith(status: ProductListStatus.loadingMore));

    final nextSkip = state.products.length;
    await _fetchCurrentView(skip: nextSkip, append: true);
  }

  void search(String query) {
    _debouncer.run(() => _executeSearch(query));
  }

  Future<void> _executeSearch(String query) async {
    if (query == state.currentQuery) return;

    if (query.isEmpty) {
      emit(state.copyWith(
        currentQuery: '',
        products: [],
        currentPage: 0,
        status: ProductListStatus.loading,
      ));
      await _fetchCurrentView(skip: 0);
      return;
    }

    emit(state.copyWith(
      currentQuery: query,
      products: [],
      currentPage: 0,
      status: ProductListStatus.loading,
    ));

    try {
      final result = await _searchProducts(query: query, limit: AppConstants.paginationLimit);
      if (result.products.isEmpty) {
        emit(state.copyWith(
          status: ProductListStatus.empty,
          products: [],
          total: 0,
          hasMore: false,
          currentQuery: query,
        ));
      } else {
        emit(state.copyWith(
          status: ProductListStatus.loaded,
          products: result.products,
          total: result.total,
          hasMore: result.products.length < result.total,
          isFromCache: result.isFromCache,
          currentQuery: query,
        ));
      }
    } catch (e) {
      AppLogger.error('search failed', error: e, tag: 'ProductListCubit');
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: _errorMessage(e),
        currentQuery: query,
      ));
    }
  }

  Future<void> selectCategory(String? category) async {
    if (category == state.selectedCategory) return;

    emit(state.copyWith(
      selectedCategory: () => category,
      products: [],
      currentPage: 0,
      currentQuery: '',
      status: ProductListStatus.loading,
      hasMore: true,
    ));

    await _fetchCurrentView(skip: 0);
  }

  Future<void> retry() async {
    await loadProducts(refresh: true);
  }

  Future<void> _fetchCurrentView({required int skip, bool append = false}) async {
    try {
      final query = state.currentQuery;
      final category = state.selectedCategory;

      final result = await (() async {
        if (query.isNotEmpty) {
          return _searchProducts(
            query: query,
            skip: skip,
            limit: AppConstants.paginationLimit,
          );
        } else if (category != null) {
          return _getProductsByCategory(
            category: category,
            skip: skip,
            limit: AppConstants.paginationLimit,
          );
        } else {
          return _getProducts(skip: skip, limit: AppConstants.paginationLimit);
        }
      })();

      final allProducts = append ? [...state.products, ...result.products] : result.products;

      if (allProducts.isEmpty && !append) {
        emit(state.copyWith(
          status: ProductListStatus.empty,
          products: [],
          total: 0,
          hasMore: false,
          isFromCache: result.isFromCache,
        ));
      } else {
        emit(state.copyWith(
          status: ProductListStatus.loaded,
          products: allProducts,
          total: result.total,
          hasMore: allProducts.length < result.total,
          currentPage: skip ~/ AppConstants.paginationLimit,
          isFromCache: result.isFromCache,
        ));
      }
    } catch (e) {
      AppLogger.error('_fetchCurrentView failed', error: e, tag: 'ProductListCubit');
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: _errorMessage(e),
      ));
    }
  }

  Future<void> _loadCategoriesIfNeeded() async {
    if (_categories.isNotEmpty) return;
    try {
      _categories = await _getCategories();
    } catch (e) {
      AppLogger.warning('Failed to load categories: $e', tag: 'ProductListCubit');
    }
  }

  String _errorMessage(Object e) {
    final str = e.toString();
    if (str.contains('No internet')) return 'No internet connection. Showing cached data.';
    if (str.contains('timed out')) return 'Request timed out. Please try again.';
    return 'Failed to load products. Please try again.';
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
