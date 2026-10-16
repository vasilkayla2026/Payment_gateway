import '../entities/payment_record.dart';

/// Source of past orders and how their payments went.
abstract interface class PaymentHistoryRepository {
  /// The most recent orders, newest first.
  Future<List<PaymentRecord>> getPaymentHistory();
}
