import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_order_id.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Runs "Proceed to pay": gets a gateway order id for the amount from the
/// backend. Provided per review screen, so every visit starts fresh.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderId _createOrderId;

  static const String errorMessage =
      'Could not start the payment. Please try again.';

  PaymentBloc(this._createOrderId) : super(const PaymentState()) {
    on<PaymentRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    if (state.isLoading) return;

    emit(const PaymentState(status: PaymentStatus.loading));
    try {
      final orderId = await _createOrderId(event.amountMinor);
      emit(PaymentState(status: PaymentStatus.orderCreated, orderId: orderId));
    } catch (error, stackTrace) {
      // Never leave the UI stuck in loading.
      addError(error, stackTrace);
      emit(
        const PaymentState(status: PaymentStatus.failure, error: errorMessage),
      );
    }
  }
}
