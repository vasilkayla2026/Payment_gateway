import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/checkout_result.dart';
import '../../domain/services/payment_checkout.dart';
import '../../domain/usecases/create_payment_order.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Runs "Add policy": the backend creates a Razorpay order, then the
/// customer pays in Razorpay Checkout. Razorpay tells the backend about the
/// payment through its webhook; the app only learns how Checkout ended.
/// Provided with the policy screen.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentOrder _createPaymentOrder;
  final PaymentCheckout _checkout;

  static const String errorMessage =
      'Could not start the payment. Please try again.';

  PaymentBloc(this._createPaymentOrder, this._checkout)
    : super(const PaymentState()) {
    on<PaymentRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    if (state.isLoading) return;

    emit(const PaymentState(status: PaymentStatus.loading));
    try {
      // 1. The backend creates the Razorpay order.
      final order = await _createPaymentOrder(event.amountMinor);
      // 2. The customer pays in Razorpay Checkout.
      final result = await _checkout.open(
        order,
        description: event.description,
      );
      emit(switch (result) {
        CheckoutPaid(:final paymentId) => PaymentState(
          status: PaymentStatus.paid,
          orderId: order.orderId,
          paymentId: paymentId,
        ),
        CheckoutClosed() => const PaymentState(status: PaymentStatus.cancelled),
      });
    } catch (error, stackTrace) {
      // Never leave the UI stuck in loading.
      addError(error, stackTrace);
      emit(
        const PaymentState(status: PaymentStatus.failure, error: errorMessage),
      );
    }
  }
}
