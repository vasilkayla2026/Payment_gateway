import 'package:equatable/equatable.dart';

/// A colour variant of a [Product].
class ProductColor extends Equatable {
  final String name;

  /// 32-bit ARGB value, e.g. `0xFF263238`.
  final int argb;

  const ProductColor({required this.name, required this.argb});

  @override
  List<Object?> get props => [name, argb];
}

/// The product on sale. Prices are integer minor units (paise).
class Product extends Equatable {
  final String id;
  final String name;
  final String tagline;
  final String description;

  /// Selling price of one unit.
  final int priceMinor;

  /// Original price (MRP) shown struck through when discounted.
  final int? compareAtPriceMinor;

  final List<String> highlights;

  /// Available colours; never empty. The first one is the default.
  final List<ProductColor> colors;

  final int maxQuantityPerOrder;

  const Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.priceMinor,
    this.compareAtPriceMinor,
    required this.highlights,
    required this.colors,
    required this.maxQuantityPerOrder,
  });

  /// Amount saved on one unit compared with [compareAtPriceMinor].
  int get savingsMinor {
    final compareAt = compareAtPriceMinor;
    if (compareAt == null || compareAt <= priceMinor) return 0;
    return compareAt - priceMinor;
  }

  /// Whole-number discount percentage, rounded down so it is never
  /// overstated.
  int get discountPercent {
    final compareAt = compareAtPriceMinor;
    if (compareAt == null || savingsMinor == 0) return 0;
    return savingsMinor * 100 ~/ compareAt;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    tagline,
    description,
    priceMinor,
    compareAtPriceMinor,
    highlights,
    colors,
    maxQuantityPerOrder,
  ];
}
