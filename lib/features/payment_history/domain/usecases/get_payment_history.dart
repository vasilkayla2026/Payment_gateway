import '../entities/payment_record.dart';
import '../repositories/payment_history_repository.dart';

/// Loads the orders shown on the payment history page.
class GetPaymentHistory {
  final PaymentHistoryRepository _repository;

  const GetPaymentHistory(this._repository);

  Future<List<PaymentRecord>> call() => _repository.getPaymentHistory();
}
