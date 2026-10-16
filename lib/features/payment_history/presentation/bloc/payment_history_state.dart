import 'package:equatable/equatable.dart';

import '../../domain/entities/payment_record.dart';

enum PaymentHistoryStatus { initial, loading, loaded, failure }

class PaymentHistoryState extends Equatable {
  final PaymentHistoryStatus status;

  /// Newest first. Kept while a refresh loads, so the list stays on screen.
  final List<PaymentRecord> records;

  /// Message for the customer; set on [PaymentHistoryStatus.failure].
  final String? error;

  const PaymentHistoryState({
    this.status = PaymentHistoryStatus.initial,
    this.records = const [],
    this.error,
  });

  bool get isLoading => status == PaymentHistoryStatus.loading;

  @override
  List<Object?> get props => [status, records, error];
}
