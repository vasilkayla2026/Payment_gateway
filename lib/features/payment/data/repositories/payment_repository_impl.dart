import '../../../../core/client/api_client.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  const PaymentRepositoryImpl(this._apiClient);

  /// `POST /request/orderId` with `{"amount": <paise>}`; expects
  /// `{"orderId": "..."}` back.
  @override
  Future<String> createOrderId(int amountMinor) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/request/orderId',
      data: {'amount': amountMinor},
    );
    final orderId = response.data?['orderId'];
    if (orderId is! String || orderId.isEmpty) {
      throw FormatException('Response has no orderId', response.data);
    }
    return orderId;
  }
}
