import '../../domain/entities/product.dart';

/// A product as delivered by a data source (API-shaped JSON).
class ProductModel {
  final String id;
  final String name;
  final String tagline;
  final String description;

  /// In minor units (paise).
  final int price;
  final int? compareAtPrice;
  final List<String> highlights;
  final List<ProductColorModel> colors;
  final int maxQuantityPerOrder;

  const ProductModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.highlights,
    required this.colors,
    required this.maxQuantityPerOrder,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      compareAtPrice: json['compareAtPrice'] as int?,
      highlights: (json['highlights'] as List).cast<String>(),
      colors: (json['colors'] as List)
          .map(
            (color) =>
                ProductColorModel.fromJson(color as Map<String, dynamic>),
          )
          .toList(),
      maxQuantityPerOrder: json['maxQuantityPerOrder'] as int? ?? 5,
    );
  }

  Product toEntity() => Product(
    id: id,
    name: name,
    tagline: tagline,
    description: description,
    priceMinor: price,
    compareAtPriceMinor: compareAtPrice,
    highlights: highlights,
    colors: colors.map((color) => color.toEntity()).toList(),
    maxQuantityPerOrder: maxQuantityPerOrder,
  );
}

/// A colour option as delivered by a data source.
class ProductColorModel {
  final String name;

  /// `#RRGGBB` or `#AARRGGBB`.
  final String hex;

  const ProductColorModel({required this.name, required this.hex});

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      name: json['name'] as String,
      hex: json['hex'] as String,
    );
  }

  ProductColor toEntity() {
    final digits = hex.replaceFirst('#', '');
    return ProductColor(
      name: name,
      argb: int.parse(digits.length == 6 ? 'FF$digits' : digits, radix: 16),
    );
  }
}
