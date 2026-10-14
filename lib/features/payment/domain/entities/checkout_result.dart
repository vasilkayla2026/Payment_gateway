import 'package:equatable/equatable.dart';

/// How Razorpay Checkout ended.
sealed class CheckoutResult extends Equatable {
  const CheckoutResult();

  @override
  List<Object?> get props => [];
}

/// The customer paid. This is Checkout's report to the app; the backend
/// learns of the payment from Razorpay's webhook.
class CheckoutPaid extends CheckoutResult {
  /// Razorpay's payment id, e.g. `pay_Xyz789`.
  final String paymentId;
  final String orderId;

  /// Lets a backend check that Razorpay sent these ids.
  final String signature;

  const CheckoutPaid({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  @override
  List<Object?> get props => [paymentId, orderId, signature];
}

/// The customer closed Checkout without paying.
class CheckoutClosed extends CheckoutResult {
  const CheckoutClosed();
}
