import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog/domain/entities/product.dart';
import 'package:product_catalog/domain/repositories/products_repository.dart';
import 'package:product_catalog/domain/usecases/get_categories_usecase.dart';
import 'package:product_catalog/domain/usecases/get_products_by_category_usecase.dart';
import 'package:product_catalog/domain/usecases/get_products_usecase.dart';
import 'package:product_catalog/domain/usecases/search_products_usecase.dart';
import 'package:product_catalog/features/product_list/cubit/product_list_cubit.dart';
import 'package:product_catalog/features/product_list/cubit/product_list_state.dart';
import 'package:product_catalog/core/utils/debouncer.dart';

// Mocks
class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}
class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}
class MockGetProductsByCategoryUseCase extends Mock implements GetProductsByCategoryUseCase {}

// Fake for Debouncer that runs immediately
class ImmediateDebouncer extends Debouncer {
  ImmediateDebouncer() : super(delay: Duration.zero);

  @override
  void run(void Function() action) => action();
}

final _sampleProducts = List.generate(
  5,
  (i) => Product(
    id: i + 1,
    title: 'Product ${i + 1}',
    description: 'Description',
    price: 10.0 * (i + 1),
    discountPercentage: 0,
    rating: 4.0,
    stock: 10,
    brand: 'Brand',
    category: 'electronics',
    thumbnail: '',
    images: [],
  ),
);

final _sampleResult = ProductsResult(
  products: _sampleProducts,
  total: 20,
  isFromCache: false,
);

void main() {
  late MockGetProductsUseCase mockGetProducts;
  late MockSearchProductsUseCase mockSearch;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockGetProductsByCategoryUseCase mockGetByCategory;

  setUp(() {
    mockGetProducts = MockGetProductsUseCase();
    mockSearch = MockSearchProductsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockGetByCategory = MockGetProductsByCategoryUseCase();

    when(() => mockGetCategories()).thenAnswer((_) async => ['electronics', 'clothing']);
  });

  ProductListCubit buildCubit() => ProductListCubit(
        getProducts: mockGetProducts,
        searchProducts: mockSearch,
        getCategories: mockGetCategories,
        getProductsByCategory: mockGetByCategory,
        debouncer: ImmediateDebouncer(),
      );

  group('ProductListCubit', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state.status, ProductListStatus.initial);
      expect(cubit.state.products, isEmpty);
      expect(cubit.state.currentQuery, '');
      expect(cubit.state.selectedCategory, isNull);
    });

    blocTest<ProductListCubit, ProductListState>(
      'loadProducts emits loading then loaded',
      build: () {
        when(() => mockGetProducts(skip: any(named: 'skip'), limit: any(named: 'limit')))
            .thenAnswer((_) async => _sampleResult);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loading),
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loaded)
            .having((s) => s.products.length, 'products length', 5)
            .having((s) => s.total, 'total', 20),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'loadProducts emits error on failure',
      build: () {
        when(() => mockGetProducts(skip: any(named: 'skip'), limit: any(named: 'limit')))
            .thenThrow(Exception('Network error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loading),
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'search calls search use case with query',
      build: () {
        when(
          () => mockSearch(
            query: any(named: 'query'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => _sampleResult);
        return buildCubit();
      },
      act: (cubit) => cubit.search('headphones'),
      expect: () => [
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loading)
            .having((s) => s.currentQuery, 'query', 'headphones'),
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loaded)
            .having((s) => s.currentQuery, 'query', 'headphones'),
      ],
      verify: (cubit) {
        verify(
          () => mockSearch(
            query: 'headphones',
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    blocTest<ProductListCubit, ProductListState>(
      'selectCategory triggers reload with category',
      build: () {
        when(
          () => mockGetByCategory(
            category: any(named: 'category'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => _sampleResult);
        return buildCubit();
      },
      act: (cubit) => cubit.selectCategory('electronics'),
      expect: () => [
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loading)
            .having((s) => s.selectedCategory, 'category', 'electronics'),
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loaded)
            .having((s) => s.selectedCategory, 'category', 'electronics'),
      ],
      verify: (cubit) {
        verify(
          () => mockGetByCategory(
            category: 'electronics',
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    blocTest<ProductListCubit, ProductListState>(
      'loadMore appends products to existing list',
      build: () {
        final moreProducts = List.generate(
          3,
          (i) => Product(
            id: i + 10,
            title: 'Product ${i + 10}',
            description: '',
            price: 10.0,
            discountPercentage: 0,
            rating: 4.0,
            stock: 10,
            brand: 'Brand',
            category: 'cat',
            thumbnail: '',
            images: [],
          ),
        );
        when(() => mockGetProducts(skip: 5, limit: 20))
            .thenAnswer((_) async => ProductsResult(
                  products: moreProducts,
                  total: 20,
                  isFromCache: false,
                ));
        return buildCubit();
      },
      seed: () => ProductListState(
        status: ProductListStatus.loaded,
        products: _sampleProducts,
        total: 20,
        hasMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loadingMore),
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loaded)
            .having((s) => s.products.length, 'products count', 8),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'loadProducts with empty result emits empty status',
      build: () {
        when(() => mockGetProducts(skip: any(named: 'skip'), limit: any(named: 'limit')))
            .thenAnswer(
              (_) async => const ProductsResult(products: [], total: 0, isFromCache: false),
            );
        return buildCubit();
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.loading),
        isA<ProductListState>()
            .having((s) => s.status, 'status', ProductListStatus.empty),
      ],
    );
  });
}
