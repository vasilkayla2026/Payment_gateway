import 'package:equatable/equatable.dart';

/// Order amounts in minor units.
class PriceBreakdown extends Equatable {
  final int itemCount;

  /// Unit price × quantity.
  final int itemsTotalMinor;

  /// Zero when the order qualifies for free delivery.
  final int deliveryFeeMinor;

  /// Saved against the original price.
  final int savingsMinor;

  const PriceBreakdown({
    required this.itemCount,
    required this.itemsTotalMinor,
    required this.deliveryFeeMinor,
    required this.savingsMinor,
  });

  bool get isFreeDelivery => deliveryFeeMinor == 0;

  /// The amount the customer pays.
  int get totalMinor => itemsTotalMinor + deliveryFeeMinor;

  @override
  List<Object?> get props => [
    itemCount,
    itemsTotalMinor,
    deliveryFeeMinor,
    savingsMinor,
  ];
}
