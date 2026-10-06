import 'package:equatable/equatable.dart';

enum PaymentStatus {
  initial,

  /// Waiting for the backend to create the order.
  loading,

  /// [PaymentState.orderId] is ready for the gateway checkout.
  orderCreated,
  failure,
}

class PaymentState extends Equatable {
  final PaymentStatus status;

  /// Gateway order id from the backend; set on [PaymentStatus.orderCreated].
  final String? orderId;

  /// Message for the customer; set on [PaymentStatus.failure].
  final String? error;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.orderId,
    this.error,
  });

  bool get isLoading => status == PaymentStatus.loading;

  @override
  List<Object?> get props => [status, orderId, error];
}
