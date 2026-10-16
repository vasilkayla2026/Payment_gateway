import '../../../../core/client/api_client.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repositories/payment_history_repository.dart';
import '../models/payment_record_model.dart';

class PaymentHistoryRepositoryImpl implements PaymentHistoryRepository {
  final ApiClient _apiClient;

  const PaymentHistoryRepositoryImpl(this._apiClient);

  /// `GET /request/orders`; expects `{"orders": [...]}`, newest first, each
  /// order as [PaymentRecordModel.fromJson] reads it.
  @override
  Future<List<PaymentRecord>> getPaymentHistory() async {
    print('orders histoy call is happpened');
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/request/orders',
    );
    final orders = response.data?['orders'];
    if (orders is! List) {
      throw FormatException('Unexpected orders response', response.data);
    }
    return [
      for (final order in orders)
        PaymentRecordModel.fromJson(order as Map<String, dynamic>).toEntity(),
    ];
  }
}
