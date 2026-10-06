import '../entities/order_item.dart';
import '../entities/price_breakdown.dart';

/// Applies the store's delivery policy to an [OrderItem].
class CalculatePriceBreakdown {
  final int deliveryFeeMinor;

  /// Item totals at or above this amount ship free.
  final int freeDeliveryThresholdMinor;

  const CalculatePriceBreakdown({
    required this.deliveryFeeMinor,
    required this.freeDeliveryThresholdMinor,
  });

  PriceBreakdown call(OrderItem item) {
    final itemsTotal = item.totalMinor;
    return PriceBreakdown(
      itemCount: item.quantity,
      itemsTotalMinor: itemsTotal,
      deliveryFeeMinor: itemsTotal >= freeDeliveryThresholdMinor
          ? 0
          : deliveryFeeMinor,
      savingsMinor: item.savingsMinor,
    );
  }
}
