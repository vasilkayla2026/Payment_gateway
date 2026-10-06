import 'package:flutter/material.dart';

/// Outlined "− 1 +" stepper. A null callback disables that button.
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            tooltip: 'Decrease quantity',
            icon: const Icon(Icons.remove),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40),
            child: Semantics(
              container: true,
              label: 'Quantity',
              value: '$quantity',
              liveRegion: true,
              excludeSemantics: true,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            tooltip: 'Increase quantity',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
