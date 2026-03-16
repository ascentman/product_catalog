import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String title;
  final String description;
  final double? price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  String get displayPrice {
    if (price == null || price! < 0) return 'Price unavailable';
    final discounted = price! * (1 - discountPercentage / 100);
    return '\$${discounted.toStringAsFixed(2)}';
  }

  String get originalPrice {
    if (price == null || price! < 0) return '';
    return '\$${price!.toStringAsFixed(2)}';
  }

  bool get hasDiscount => discountPercentage > 0 && price != null && price! >= 0;

  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        discountPercentage,
        rating,
        stock,
        brand,
        category,
        thumbnail,
        images,
      ];
}
