import '../entities/payment_order.dart';

abstract interface class PaymentRepository {
  /// Asks the backend to create a Razorpay order for [amountMinor] (paise).
  Future<PaymentOrder> createOrder(int amountMinor);
}
