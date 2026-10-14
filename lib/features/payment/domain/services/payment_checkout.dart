import '../entities/checkout_result.dart';
import '../entities/payment_order.dart';

/// The payment gateway's checkout, where the customer pays.
abstract interface class PaymentCheckout {
  /// Opens checkout for [order] and completes when it closes. [description]
  /// says what is being paid for.
  Future<CheckoutResult> open(
    PaymentOrder order, {
    required String description,
  });
}
