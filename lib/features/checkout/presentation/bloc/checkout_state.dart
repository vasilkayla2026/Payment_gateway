import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_details.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/price_breakdown.dart';

class CheckoutState extends Equatable {
  /// What is being bought; set when the customer taps "Buy now".
  final OrderItem? item;

  /// Amounts for [item].
  final PriceBreakdown? pricing;

  /// Saved contact details; kept across checkouts.
  final CustomerDetails? customer;

  const CheckoutState({this.item, this.pricing, this.customer});

  CheckoutState copyWith({
    OrderItem? item,
    PriceBreakdown? pricing,
    CustomerDetails? customer,
  }) {
    return CheckoutState(
      item: item ?? this.item,
      pricing: pricing ?? this.pricing,
      customer: customer ?? this.customer,
    );
  }

  @override
  List<Object?> get props => [item, pricing, customer];
}
