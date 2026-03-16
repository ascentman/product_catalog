import '../../domain/entities/product.dart';
import '../../core/utils/logger.dart';

class ProductModel {
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

  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    double? parsedPrice;

    if (rawPrice == null) {
      AppLogger.error('Missing price for product id=${json['id']}', tag: 'ProductModel');
      parsedPrice = null;
    } else {
      final numPrice = (rawPrice as num).toDouble();
      if (numPrice < 0) {
        AppLogger.error('Negative price $numPrice for product id=${json['id']}', tag: 'ProductModel');
        parsedPrice = null;
      } else {
        parsedPrice = numPrice;
      }
    }

    final rawBrand = json['brand'] as String?;
    if (rawBrand == null || rawBrand.isEmpty) {
      AppLogger.warning('Missing brand for product id=${json['id']}', tag: 'ProductModel');
    }

    final rawImages = json['images'] as List<dynamic>?;
    if (rawImages == null || rawImages.isEmpty) {
      AppLogger.warning('Missing images for product id=${json['id']}', tag: 'ProductModel');
    }

    final rawThumbnail = json['thumbnail'] as String?;
    if (rawThumbnail == null || rawThumbnail.isEmpty) {
      AppLogger.warning('Missing thumbnail for product id=${json['id']}', tag: 'ProductModel');
    }

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.isNotEmpty == true
          ? json['title'] as String
          : 'Unknown Product',
      description: json['description'] as String? ?? '',
      price: parsedPrice,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: (json['brand'] as String?)?.isNotEmpty == true
          ? json['brand'] as String
          : 'Unknown Brand',
      category: json['category'] as String? ?? '',
      thumbnail: rawThumbnail ?? '',
      images: rawImages?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'brand': brand,
        'category': category,
        'thumbnail': thumbnail,
        'images': images,
      };

  Product toEntity() => Product(
        id: id,
        title: title,
        description: description,
        price: price,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        brand: brand,
        category: category,
        thumbnail: thumbnail,
        images: images,
      );
}
