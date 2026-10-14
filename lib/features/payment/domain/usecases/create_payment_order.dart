import '../entities/payment_order.dart';
import '../repositories/payment_repository.dart';

/// Creates the Razorpay order that Checkout is opened with.
class CreatePaymentOrder {
  final PaymentRepository _repository;

  const CreatePaymentOrder(this._repository);

  Future<PaymentOrder> call(int amountMinor) =>
      _repository.createOrder(amountMinor);
}
