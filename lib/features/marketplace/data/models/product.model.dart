import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double discount;
  final int stock;
  final double rating;
  final int reviewCount;
  final String storeId;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.discount = 0,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.storeId,
  });

  double get finalPrice => price * (1 - (discount / 100));

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        price,
        discount,
        stock,
        rating,
        reviewCount,
        storeId,
      ];

  factory Product.fromJson(Map<String, dynamic> json) {
    // Maneja tanto el formato del backend (snake_case) como el del frontend (camelCase)
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['image']) as String? ?? '',
      price: _parseDouble(json['price']),
      discount: _parseDouble(json['discount']),
      stock: json['stock'] as int? ?? 0,
      rating: _parseDouble(json['rating']),
      reviewCount: (json['review_count'] ?? json['reviewCount']) as int? ?? 0,
      storeId: (json['store_id'] ?? json['storeId'] ?? json['store']).toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'discount': discount,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'storeId': storeId,
    };
  }
}
