import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/product.dart';

/// Unit price, plus the struck-through original price and discount badge
/// when the product is on sale.
class ProductPrice extends StatelessWidget {
  const ProductPrice({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final price = formatMoney(product.priceMinor);
    final compareAt = product.compareAtPriceMinor;
    final onSale = compareAt != null && product.savingsMinor > 0;
    final wasPrice = onSale ? formatMoney(compareAt) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Semantics(
          label: wasPrice == null
              ? 'Price $price'
              : 'Price $price, was $wasPrice, ${product.discountPercent}% off',
          excludeSemantics: true,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                price,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (wasPrice != null) ...[
                Text(
                  wasPrice,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: colorScheme.onSurfaceVariant,
                  ),
                ),
                _DiscountBadge(percent: product.discountPercent),
              ],
            ],
          ),
        ),
        Text(
          'Inclusive of all taxes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '$percent% off',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
