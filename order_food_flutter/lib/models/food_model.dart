part of '../main.dart';

class Food {
  const Food({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.category,
    required this.restaurant,
    this.description = '',
    this.rating = 4.7,
    this.sold = 0,
    this.discountPercent = 0,
    this.tags = const [],
  });

  final int id;
  final String name;
  final int price;
  final int originalPrice;
  final String image;
  final String category;
  final String restaurant;
  final String description;
  final double rating;
  final int sold;
  final int discountPercent;
  final List<String> tags;

  factory Food.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    final price = _asInt(data['price']);
    final id = _asInt(data['id']);
    return Food(
      id: id,
      name: (data['name'] ?? '').toString(),
      price: price,
      originalPrice: _asInt(data['originalPrice'], fallback: price),
      image: _imageFor(id, (data['image'] ?? '').toString()),
      category: (data['category'] ?? 'Món ngon').toString(),
      restaurant: (data['restaurant'] ?? AppConstants.defaultRestaurant)
          .toString(),
      description: (data['description'] ?? '').toString(),
      rating: _asDouble(data['rating'], fallback: 4.7),
      sold: _asInt(data['sold'], fallback: 120),
      discountPercent: _asInt(data['discountPercent']),
      tags: ((data['tags'] as List?) ?? const [])
          .map((tag) => tag.toString())
          .where((tag) => tag.isNotEmpty)
          .toList(),
    );
  }
}
