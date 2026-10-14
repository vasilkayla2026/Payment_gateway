import 'package:equatable/equatable.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// "Add policy": pay [amountMinor] (paise) for what [description] names.
/// Ignored while a payment is already running.
class PaymentRequested extends PaymentEvent {
  final int amountMinor;
  final String description;

  const PaymentRequested(this.amountMinor, {required this.description});

  @override
  List<Object?> get props => [amountMinor, description];
}
