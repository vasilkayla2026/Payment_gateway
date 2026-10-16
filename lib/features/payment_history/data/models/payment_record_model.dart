import '../../domain/entities/payment_record.dart';

/// An order as `GET /request/orders` delivers it. Amounts are in paise.
class PaymentRecordModel {
  final String orderId;
  final int amount;

  /// `created`, `paid` or `failed`.
  final String status;
  final String? paymentId;

  /// ISO 8601, e.g. `2026-10-16T09:07:51.019Z`.
  final String createdAt;

  const PaymentRecordModel({
    required this.orderId,
    required this.amount,
    required this.status,
    required this.paymentId,
    required this.createdAt,
  });

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) {
    return PaymentRecordModel(
      orderId: json['orderId'] as String,
      amount: json['amount'] as int,
      status: json['status'] as String,
      paymentId: json['paymentId'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Throws a [FormatException] for a status or date the app can't read.
  PaymentRecord toEntity() {
    return PaymentRecord(
      orderId: orderId,
      amountMinor: amount,
      status: switch (status) {
        'created' => PaymentRecordStatus.pending,
        'paid' => PaymentRecordStatus.paid,
        'failed' => PaymentRecordStatus.failed,
        _ => throw FormatException('Order $orderId has unknown status', status),
      },
      paymentId: paymentId,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
