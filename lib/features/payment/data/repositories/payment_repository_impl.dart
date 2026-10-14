import '../../../../core/client/api_client.dart';
import '../../domain/entities/payment_order.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  const PaymentRepositoryImpl(this._apiClient);

  /// `POST /request/orderId` with `{"amount": <paise>}`; expects
  /// `{"orderId", "amount", "currency", "keyId"}` back.
  @override
  Future<PaymentOrder> createOrder(int amountMinor) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/request/orderId',
      data: {'amount': amountMinor},
    );
    final data = response.data;
    final orderId = data?['orderId'];
    final amount = data?['amount'];
    final currency = data?['currency'];
    final keyId = data?['keyId'];
    if (orderId is! String ||
        amount is! int ||
        currency is! String ||
        keyId is! String) {
      throw FormatException('Unexpected order response', data);
    }
    return PaymentOrder(
      orderId: orderId,
      amountMinor: amount,
      currency: currency,
      keyId: keyId,
    );
  }
}
