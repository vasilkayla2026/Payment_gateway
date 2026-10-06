import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/price_breakdown.dart';

/// Review-step card itemising the order amounts: items, delivery and the
/// total, plus savings and the free-delivery hint when relevant.
class OrderPriceDetailsCard extends StatelessWidget {
  const OrderPriceDetailsCard({super.key, required this.pricing});

  final PriceBreakdown pricing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemNoun = pricing.itemCount == 1 ? 'item' : 'items';
    final totalStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Price details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _PriceRow(
              label: 'Price (${pricing.itemCount} $itemNoun)',
              value: formatMoney(pricing.itemsTotalMinor),
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Delivery',
              value: pricing.isFreeDelivery
                  ? 'FREE'
                  : formatMoney(pricing.deliveryFeeMinor),
              valueStyle: pricing.isFreeDelivery
                  ? theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    )
                  : null,
            ),
            const Divider(height: 24),
            _PriceRow(
              label: 'Total amount',
              value: formatMoney(pricing.totalMinor),
              labelStyle: totalStyle,
              valueStyle: totalStyle,
            ),
            if (pricing.savingsMinor > 0) ...[
              const SizedBox(height: 12),
              Text(
                'You save ${formatMoney(pricing.savingsMinor)} on this order',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (!pricing.isFreeDelivery) ...[
              const SizedBox(height: 8),
              Text(
                'Free delivery on orders of '
                '${formatMoney(AppConfig.freeDeliveryThresholdMinor)} or more',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Label on the left, amount on the right. The amount keeps its natural
/// width (shrinking only if it would take more than 60% of the row); the
/// label takes the rest and wraps.
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;

  /// Defaults to bodyMedium.
  final TextStyle? labelStyle;

  /// Defaults to bodyMedium.
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return MergeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: labelStyle ?? bodyStyle)),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(value, maxLines: 1, style: valueStyle ?? bodyStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
