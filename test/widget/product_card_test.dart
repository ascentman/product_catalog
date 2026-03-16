import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/design_system/components/product_card.dart';
import 'package:product_catalog/domain/entities/product.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 220,
          height: 360,
          child: child,
        ),
      ),
    ),
  );
}

final _productWithDiscount = Product(
  id: 1,
  title: 'Test Product',
  description: 'A test product.',
  price: 100.0,
  discountPercentage: 20.0,
  rating: 4.5,
  stock: 10,
  brand: 'TestBrand',
  category: 'electronics',
  thumbnail: '',
  images: [],
);

final _productNullPrice = Product(
  id: 2,
  title: 'No Price Product',
  description: 'No price set.',
  price: null,
  discountPercentage: 0,
  rating: 3.0,
  stock: 5,
  brand: 'BrandX',
  category: 'misc',
  thumbnail: '',
  images: [],
);

final _productNoDiscount = Product(
  id: 3,
  title: 'Regular Product',
  description: 'Normal product.',
  price: 50.0,
  discountPercentage: 0,
  rating: 3.5,
  stock: 2,
  brand: 'BrandY',
  category: 'clothing',
  thumbnail: '',
  images: [],
);

void main() {
  group('ProductCard', () {
    testWidgets('renders product title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productWithDiscount, onTap: () {}),
        ),
      );
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('renders brand name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productWithDiscount, onTap: () {}),
        ),
      );
      expect(find.text('TestBrand'), findsOneWidget);
    });

    testWidgets('renders Price unavailable when price is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productNullPrice, onTap: () {}),
        ),
      );
      expect(find.text('Price unavailable'), findsOneWidget);
    });

    testWidgets('renders discount badge when discountPercentage > 0', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productWithDiscount, onTap: () {}),
        ),
      );
      expect(find.text('-20%'), findsOneWidget);
    });

    testWidgets('does not render discount badge when discountPercentage is 0', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productNoDiscount, onTap: () {}),
        ),
      );
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(
            product: _productWithDiscount,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(ProductCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('shows discounted price formatted correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productWithDiscount, onTap: () {}),
        ),
      );
      // 100 * (1 - 0.20) = 80.00
      expect(find.text('\$80.00'), findsOneWidget);
    });

    testWidgets('renders original price with strikethrough for discounted product',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProductCard(product: _productWithDiscount, onTap: () {}),
        ),
      );
      expect(find.text('\$100.00'), findsOneWidget);
    });
  });
}
