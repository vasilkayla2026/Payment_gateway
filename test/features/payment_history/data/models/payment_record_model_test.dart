import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/features/payment_history/data/models/payment_record_model.dart';
import 'package:payment_gateway/features/payment_history/domain/entities/payment_record.dart';

/// An order as `GET /request/orders` sends it.
Map<String, dynamic> _orderJson({required String status, String? paymentId}) =>
    {
      'orderId': 'order_123',
      'amount': 824000,
      'currency': 'INR',
      'status': status,
      'paymentId': ?paymentId,
      'createdAt': '2026-10-16T09:07:51.019Z',
    };

void main() {
  test('reads a paid order', () {
    final record = PaymentRecordModel.fromJson(
      _orderJson(status: 'paid', paymentId: 'pay_456'),
    ).toEntity();

    expect(
      record,
      PaymentRecord(
        orderId: 'order_123',
        amountMinor: 824000,
        status: PaymentRecordStatus.paid,
        paymentId: 'pay_456',
        createdAt: DateTime.utc(2026, 10, 16, 9, 7, 51, 19),
      ),
    );
  });

  test('an order the webhook has not marked yet is pending', () {
    final record = PaymentRecordModel.fromJson(
      _orderJson(status: 'created'),
    ).toEntity();

    expect(record.status, PaymentRecordStatus.pending);
    expect(record.paymentId, isNull);
  });

  test('reads a failed order', () {
    final record = PaymentRecordModel.fromJson(
      _orderJson(status: 'failed'),
    ).toEntity();

    expect(record.status, PaymentRecordStatus.failed);
  });

  test('rejects a status the app does not know', () {
    final model = PaymentRecordModel.fromJson(_orderJson(status: 'refunded'));

    expect(model.toEntity, throwsFormatException);
  });
}
