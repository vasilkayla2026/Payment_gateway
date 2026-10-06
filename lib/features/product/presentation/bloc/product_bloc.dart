import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_product.dart';
import 'product_event.dart';
import 'product_state.dart';

/// Drives the product screen: loads the product and tracks the chosen colour
/// and quantity.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProduct _getProduct;

  ProductBloc(this._getProduct) : super(const ProductState()) {
    on<ProductRequested>(_onRequested);
    on<ProductColorSelected>(_onColorSelected);
    on<ProductQuantityIncremented>(_onQuantityIncremented);
    on<ProductQuantityDecremented>(_onQuantityDecremented);
  }

  Future<void> _onRequested(
    ProductRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading, clearError: true));
    try {
      final product = await _getProduct();
      emit(
        ProductState(
          status: ProductStatus.loaded,
          product: product,
          selectedColor: product.colors.first,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          error: 'Could not load the product. Please try again.',
        ),
      );
    }
  }

  void _onColorSelected(
    ProductColorSelected event,
    Emitter<ProductState> emit,
  ) {
    final product = state.product;
    if (product == null || !product.colors.contains(event.color)) return;
    emit(state.copyWith(selectedColor: event.color));
  }

  void _onQuantityIncremented(
    ProductQuantityIncremented event,
    Emitter<ProductState> emit,
  ) {
    if (!state.canIncrementQuantity) return;
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void _onQuantityDecremented(
    ProductQuantityDecremented event,
    Emitter<ProductState> emit,
  ) {
    if (!state.canDecrementQuantity) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }
}
