import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_details.dart';
import '../../domain/entities/order_item.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// "Buy now": start a new checkout for [item]. Saved customer details are
/// kept so the details form is prefilled.
class CheckoutStarted extends CheckoutEvent {
  final OrderItem item;

  const CheckoutStarted(this.item);

  @override
  List<Object?> get props => [item];
}

/// The contact details form was submitted with valid values.
class CheckoutCustomerDetailsSubmitted extends CheckoutEvent {
  final CustomerDetails customer;

  const CheckoutCustomerDetailsSubmitted(this.customer);

  @override
  List<Object?> get props => [customer];
}
