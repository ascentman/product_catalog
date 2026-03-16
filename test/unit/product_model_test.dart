import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    final completeJson = {
      'id': 1,
      'title': 'iPhone 9',
      'description': 'An apple mobile which is nothing like apple.',
      'price': 549.99,
      'discountPercentage': 12.96,
      'rating': 4.69,
      'stock': 94,
      'brand': 'Apple',
      'category': 'smartphones',
      'thumbnail': 'https://cdn.dummyjson.com/product-images/1/thumbnail.jpg',
      'images': [
        'https://cdn.dummyjson.com/product-images/1/1.jpg',
        'https://cdn.dummyjson.com/product-images/1/2.jpg',
      ],
    };

    test('fromJson with complete data parses all fields correctly', () {
      final model = ProductModel.fromJson(completeJson);

      expect(model.id, 1);
      expect(model.title, 'iPhone 9');
      expect(model.description, 'An apple mobile which is nothing like apple.');
      expect(model.price, 549.99);
      expect(model.discountPercentage, 12.96);
      expect(model.rating, 4.69);
      expect(model.stock, 94);
      expect(model.brand, 'Apple');
      expect(model.category, 'smartphones');
      expect(model.thumbnail, 'https://cdn.dummyjson.com/product-images/1/thumbnail.jpg');
      expect(model.images.length, 2);
    });

    test('fromJson with missing brand defaults to Unknown Brand', () {
      final json = Map<String, dynamic>.from(completeJson)..remove('brand');
      final model = ProductModel.fromJson(json);
      expect(model.brand, 'Unknown Brand');
    });

    test('fromJson with empty brand string defaults to Unknown Brand', () {
      final model = ProductModel.fromJson({...completeJson, 'brand': ''});
      expect(model.brand, 'Unknown Brand');
    });

    test('fromJson with negative price results in null price', () {
      final json = {...completeJson, 'price': -10.0};
      final model = ProductModel.fromJson(json);
      expect(model.price, isNull);
    });

    test('fromJson with null price results in null price', () {
      final json = Map<String, dynamic>.from(completeJson)..remove('price');
      final model = ProductModel.fromJson(json);
      expect(model.price, isNull);
    });

    test('fromJson with empty images list returns empty list', () {
      final json = {...completeJson, 'images': []};
      final model = ProductModel.fromJson(json);
      expect(model.images, isEmpty);
    });

    test('fromJson with missing images returns empty list', () {
      final json = Map<String, dynamic>.from(completeJson)..remove('images');
      final model = ProductModel.fromJson(json);
      expect(model.images, isEmpty);
    });

    test('fromJson with missing title defaults to Unknown Product', () {
      final json = Map<String, dynamic>.from(completeJson)..remove('title');
      final model = ProductModel.fromJson(json);
      expect(model.title, 'Unknown Product');
    });

    test('toEntity maps all fields correctly', () {
      final model = ProductModel.fromJson(completeJson);
      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.title, model.title);
      expect(entity.description, model.description);
      expect(entity.price, model.price);
      expect(entity.discountPercentage, model.discountPercentage);
      expect(entity.rating, model.rating);
      expect(entity.stock, model.stock);
      expect(entity.brand, model.brand);
      expect(entity.category, model.category);
      expect(entity.thumbnail, model.thumbnail);
      expect(entity.images, model.images);
    });

    test('toJson roundtrip preserves data', () {
      final model = ProductModel.fromJson(completeJson);
      final json = model.toJson();
      final model2 = ProductModel.fromJson(json);

      expect(model2.id, model.id);
      expect(model2.title, model.title);
      expect(model2.price, model.price);
    });
  });

  group('Product entity display helpers', () {
    test('displayPrice shows formatted discounted price', () {
      final model = ProductModel.fromJson({
        'id': 1,
        'title': 'Test',
        'description': '',
        'price': 100.0,
        'discountPercentage': 10.0,
        'rating': 4.0,
        'stock': 5,
        'brand': 'Brand',
        'category': 'cat',
        'thumbnail': '',
        'images': [],
      });
      final entity = model.toEntity();
      expect(entity.displayPrice, '\$90.00');
    });

    test('displayPrice returns price unavailable for null price', () {
      final model = ProductModel.fromJson({
        'id': 2,
        'title': 'Test',
        'description': '',
        'price': null,
        'discountPercentage': 0.0,
        'rating': 4.0,
        'stock': 5,
        'brand': 'Brand',
        'category': 'cat',
        'thumbnail': '',
        'images': [],
      });
      final entity = model.toEntity();
      expect(entity.displayPrice, 'Price unavailable');
    });

    test('hasDiscount is false when discountPercentage is 0', () {
      final model = ProductModel.fromJson({
        'id': 3,
        'title': 'Test',
        'description': '',
        'price': 50.0,
        'discountPercentage': 0.0,
        'rating': 4.0,
        'stock': 5,
        'brand': 'Brand',
        'category': 'cat',
        'thumbnail': '',
        'images': [],
      });
      final entity = model.toEntity();
      expect(entity.hasDiscount, false);
    });
  });
}
