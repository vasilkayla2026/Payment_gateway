import 'package:equatable/equatable.dart';

enum PaymentStatus {
  initial,

  /// Creating the order, or waiting for the customer in Razorpay Checkout.
  loading,

  /// Checkout reports the payment done; [PaymentState.orderId] and
  /// [PaymentState.paymentId] are set.
  paid,

  /// The customer closed Checkout without paying.
  cancelled,
  failure,
}

class PaymentState extends Equatable {
  final PaymentStatus status;

  /// Razorpay's order id; set on [PaymentStatus.paid].
  final String? orderId;

  /// Razorpay's payment id; set on [PaymentStatus.paid].
  final String? paymentId;

  /// Message for the customer; set on [PaymentStatus.failure].
  final String? error;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.orderId,
    this.paymentId,
    this.error,
  });

  bool get isLoading => status == PaymentStatus.loading;

  @override
  List<Object?> get props => [status, orderId, paymentId, error];
}
