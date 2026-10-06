abstract interface class PaymentRepository {
  /// Asks the backend to create a payment-gateway order for [amountMinor]
  /// (paise) and returns its order id.
  Future<String> createOrderId(int amountMinor);
}
