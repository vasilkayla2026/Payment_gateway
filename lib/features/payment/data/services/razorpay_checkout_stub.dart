import '../../domain/entities/checkout_result.dart';
import '../../domain/entities/payment_order.dart';
import '../../domain/services/payment_checkout.dart';

/// Stands in for Razorpay Checkout off the web, where checkout.js can't run.
class RazorpayCheckout implements PaymentCheckout {
  const RazorpayCheckout();

  @override
  Future<CheckoutResult> open(
    PaymentOrder order, {
    required String description,
  }) {
    throw UnsupportedError('Razorpay Checkout runs in the web build only.');
  }
}
