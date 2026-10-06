import 'package:equatable/equatable.dart';

import '../../../product/domain/entities/product.dart';

/// A product, colour and quantity being bought.
class OrderItem extends Equatable {
  final Product product;
  final ProductColor color;
  final int quantity;

  const OrderItem({
    required this.product,
    required this.color,
    required this.quantity,
  });

  /// Unit price × quantity, in minor units.
  int get totalMinor => product.priceMinor * quantity;

  /// Saved against the original price across all units.
  int get savingsMinor => product.savingsMinor * quantity;

  @override
  List<Object?> get props => [product, color, quantity];
}
