import 'package:equatable/equatable.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// "Proceed to pay" for [amountMinor] (paise). Ignored while a request is
/// already running.
class PaymentRequested extends PaymentEvent {
  final int amountMinor;

  const PaymentRequested(this.amountMinor);

  @override
  List<Object?> get props => [amountMinor];
}
