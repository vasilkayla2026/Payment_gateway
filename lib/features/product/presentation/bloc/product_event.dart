import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load the product (also used to retry after a failure).
class ProductRequested extends ProductEvent {
  const ProductRequested();
}

/// The customer tapped a colour swatch.
class ProductColorSelected extends ProductEvent {
  final ProductColor color;

  const ProductColorSelected(this.color);

  @override
  List<Object?> get props => [color];
}

class ProductQuantityIncremented extends ProductEvent {
  const ProductQuantityIncremented();
}

class ProductQuantityDecremented extends ProductEvent {
  const ProductQuantityDecremented();
}
