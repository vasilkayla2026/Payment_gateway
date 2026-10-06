import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../domain/entities/order_item.dart';

/// Review-step card showing what is being bought: thumbnail, name, colour,
/// quantity and the line total.
class OrderItemCard extends StatelessWidget {
  const OrderItemCard({super.key, required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 72,
              child: ProductImagePlaceholder(
                color: Color(item.color.argb),
                semanticLabel: '${item.product.name}, ${item.color.name}',
                borderRadius: 12,
              ),
            ),
            const SizedBox(width: 16),
            // The price sits under the details rather than in a third column,
            // so the text keeps the full width on narrow screens.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Colour: ${item.color.name}', style: detailStyle),
                  Text('Quantity: ${item.quantity}', style: detailStyle),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(item.totalMinor),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.quantity > 1)
                    Text(
                      '${formatMoney(item.product.priceMinor)} each',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
