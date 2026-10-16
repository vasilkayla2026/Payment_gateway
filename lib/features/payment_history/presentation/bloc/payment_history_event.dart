import 'package:equatable/equatable.dart';

sealed class PaymentHistoryEvent extends Equatable {
  const PaymentHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load the history (also used to refresh it and to retry after a failure).
/// Ignored while a load is already running.
class PaymentHistoryRequested extends PaymentHistoryEvent {
  const PaymentHistoryRequested();
}
