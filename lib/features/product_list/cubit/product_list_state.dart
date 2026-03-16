import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

enum ProductListStatus {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
  empty,
}

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<Product> products;
  final String? errorMessage;
  final String currentQuery;
  final String? selectedCategory;
  final int currentPage;
  final bool hasMore;
  final int total;
  final bool isFromCache;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.errorMessage,
    this.currentQuery = '',
    this.selectedCategory,
    this.currentPage = 0,
    this.hasMore = true,
    this.total = 0,
    this.isFromCache = false,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    String? errorMessage,
    String? currentQuery,
    String? Function()? selectedCategory,
    int? currentPage,
    bool? hasMore,
    int? total,
    bool? isFromCache,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
      currentQuery: currentQuery ?? this.currentQuery,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        errorMessage,
        currentQuery,
        selectedCategory,
        currentPage,
        hasMore,
        total,
        isFromCache,
      ];
}
