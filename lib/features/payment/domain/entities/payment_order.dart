import 'package:equatable/equatable.dart';

/// A Razorpay order the backend created: what Checkout is opened with.
class PaymentOrder extends Equatable {
  /// Razorpay's order id, e.g. `order_Abc123`.
  final String orderId;

  /// In minor units (paise), as Razorpay created the order.
  final int amountMinor;

  /// ISO 4217 code, e.g. `INR`.
  final String currency;

  /// The Razorpay key id Checkout is opened with. It is public; the key
  /// secret stays on the backend.
  final String keyId;

  const PaymentOrder({
    required this.orderId,
    required this.amountMinor,
    required this.currency,
    required this.keyId,
  });

  @override
  List<Object?> get props => [orderId, amountMinor, currency, keyId];
}
