import '../repositories/payment_repository.dart';

/// Creates the gateway order the checkout is opened with.
class CreateOrderId {
  final PaymentRepository _repository;

  const CreateOrderId(this._repository);

  Future<String> call(int amountMinor) =>
      _repository.createOrderId(amountMinor);
}
