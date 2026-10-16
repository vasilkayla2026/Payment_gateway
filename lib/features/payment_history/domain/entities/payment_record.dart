import 'package:equatable/equatable.dart';

/// How the payment for a [PaymentRecord] went, as Razorpay's webhook told
/// the backend.
enum PaymentRecordStatus {
  /// No word from Razorpay yet: the customer is still in Checkout or closed
  /// it without paying, or the webhook has not arrived.
  pending,
  paid,
  failed,
}

/// One order in the payment history.
class PaymentRecord extends Equatable {
  /// Razorpay's order id, e.g. `order_Abc123`.
  final String orderId;

  /// In minor units (paise).
  final int amountMinor;

  final PaymentRecordStatus status;

  /// Razorpay's payment id, e.g. `pay_Xyz789`; set once paid.
  final String? paymentId;

  /// When the backend created the order, as the customer started paying.
  final DateTime createdAt;

  const PaymentRecord({
    required this.orderId,
    required this.amountMinor,
    required this.status,
    this.paymentId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    orderId,
    amountMinor,
    status,
    paymentId,
    createdAt,
  ];
}
