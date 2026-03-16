import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog/domain/entities/product.dart';
import 'package:product_catalog/domain/usecases/get_product_detail_usecase.dart';
import 'package:product_catalog/features/product_detail/cubit/product_detail_cubit.dart';
import 'package:product_catalog/features/product_detail/cubit/product_detail_state.dart';

class MockGetProductDetailUseCase extends Mock implements GetProductDetailUseCase {}

final _sampleProduct = Product(
  id: 1,
  title: 'iPhone 9',
  description: 'A great phone.',
  price: 549.99,
  discountPercentage: 12.96,
  rating: 4.69,
  stock: 94,
  brand: 'Apple',
  category: 'smartphones',
  thumbnail: 'https://example.com/thumb.jpg',
  images: ['https://example.com/img1.jpg'],
);

void main() {
  late MockGetProductDetailUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetProductDetailUseCase();
  });

  ProductDetailCubit buildCubit() =>
      ProductDetailCubit(getProductDetail: mockUseCase);

  group('ProductDetailCubit', () {
    test('initial state is correct', () {
      expect(buildCubit().state.status, ProductDetailStatus.initial);
      expect(buildCubit().state.product, isNull);
    });

    blocTest<ProductDetailCubit, ProductDetailState>(
      'loadProduct emits loading then loaded on success',
      build: () {
        when(() => mockUseCase(1)).thenAnswer((_) async => _sampleProduct);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProduct(1),
      expect: () => [
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loading),
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loaded)
            .having((s) => s.product, 'product', _sampleProduct),
      ],
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'loadProduct emits loading then error on failure',
      build: () {
        when(() => mockUseCase(999)).thenThrow(Exception('Product not found'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProduct(999),
      expect: () => [
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loading),
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'retry calls loadProduct again',
      build: () {
        when(() => mockUseCase(1)).thenAnswer((_) async => _sampleProduct);
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProduct(1);
        await cubit.retry(1);
      },
      expect: () => [
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loading),
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loaded),
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loading),
        isA<ProductDetailState>()
            .having((s) => s.status, 'status', ProductDetailStatus.loaded),
      ],
      verify: (_) => verify(() => mockUseCase(1)).called(2),
    );
  });
}
