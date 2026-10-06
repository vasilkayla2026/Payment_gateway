import 'package:equatable/equatable.dart';

import '../../../checkout/domain/entities/order_item.dart';
import '../../domain/entities/product.dart';

enum ProductStatus { initial, loading, loaded, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final Product? product;
  final ProductColor? selectedColor;
  final int quantity;
  final String? error;

  const ProductState({
    this.status = ProductStatus.initial,
    this.product,
    this.selectedColor,
    this.quantity = 1,
    this.error,
  });

  bool get canIncrementQuantity {
    final product = this.product;
    return product != null && quantity < product.maxQuantityPerOrder;
  }

  bool get canDecrementQuantity => quantity > 1;

  /// The customer's current choice as an order line; null until the product
  /// has loaded.
  OrderItem? get selection {
    final product = this.product;
    final color = selectedColor;
    if (product == null || color == null) return null;
    return OrderItem(product: product, color: color, quantity: quantity);
  }

  ProductState copyWith({
    ProductStatus? status,
    Product? product,
    ProductColor? selectedColor,
    int? quantity,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      product: product ?? this.product,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, product, selectedColor, quantity, error];
}
