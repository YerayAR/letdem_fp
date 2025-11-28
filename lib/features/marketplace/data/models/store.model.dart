import 'package:equatable/equatable.dart';

enum StoreCategory {
  clothing,
  gasoline,
  commerce,
  restaurant,
  pharmacy,
  supermarket,
  technology,
  sports,
  automotive,
  other;

  String get displayName {
    return switch (this) {
      StoreCategory.clothing => 'Ropa',
      StoreCategory.gasoline => 'Gasolina',
      StoreCategory.commerce => 'Comercio',
      StoreCategory.restaurant => 'Restaurante',
      StoreCategory.pharmacy => 'Farmacia',
      StoreCategory.supermarket => 'Supermercado',
      StoreCategory.technology => 'Tecnología',
      StoreCategory.sports => 'Deportes',
      StoreCategory.automotive => 'Automotriz',
      StoreCategory.other => 'Otro',
    };
  }

  String get icon {
    return switch (this) {
      StoreCategory.clothing => '👕',
      StoreCategory.gasoline => '⛽',
      StoreCategory.commerce => '🏪',
      StoreCategory.restaurant => '🍽️',
      StoreCategory.pharmacy => '💊',
      StoreCategory.supermarket => '🛒',
      StoreCategory.technology => '💻',
      StoreCategory.sports => '⚽',
      StoreCategory.automotive => '🚗',
      StoreCategory.other => '📍',
    };
  }
}

class Store extends Equatable {
  final String id;
  final String name;
  final String description;
  final StoreCategory category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String address;
  final String phone;
  final bool isOpen;
  final String openingHours;

  const Store({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.address,
    required this.phone,
    this.isOpen = true,
    required this.openingHours,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        imageUrl,
        latitude,
        longitude,
        rating,
        reviewCount,
        address,
        phone,
        isOpen,
        openingHours,
      ];

  factory Store.fromJson(Map<String, dynamic> json) {
    // Maneja tanto el formato del backend (snake_case) como el del frontend (camelCase)
    String? categoryName;
    if (json['category'] is Map) {
      categoryName = json['category']['name'] as String?;
    } else if (json['category'] is String) {
      categoryName = json['category'] as String;
    }
    
    return Store(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: _parseCategoryFromName(categoryName ?? 'other'),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['image']) as String? ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      rating: _parseDouble(json['rating']),
      reviewCount: (json['review_count'] ?? json['reviewCount']) as int? ?? 0,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isOpen: (json['is_open'] ?? json['isOpen']) as bool? ?? true,
      openingHours: (json['opening_hours'] ?? json['openingHours']) as String? ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static StoreCategory _parseCategoryFromName(String name) {
    switch (name.toLowerCase()) {
      case 'fashion':
      case 'clothing':
        return StoreCategory.clothing;
      case 'gas_station':
      case 'gasoline':
        return StoreCategory.gasoline;
      case 'automotive':
        return StoreCategory.automotive;
      case 'commerce':
      case 'home':
        return StoreCategory.commerce;
      case 'restaurant':
      case 'food':
        return StoreCategory.restaurant;
      case 'pharmacy':
      case 'health':
        return StoreCategory.pharmacy;
      case 'supermarket':
        return StoreCategory.supermarket;
      case 'technology':
        return StoreCategory.technology;
      case 'sports':
        return StoreCategory.sports;
      default:
        return StoreCategory.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'phone': phone,
      'isOpen': isOpen,
      'openingHours': openingHours,
    };
  }
}
