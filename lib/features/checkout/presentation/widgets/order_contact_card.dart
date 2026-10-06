import 'package:flutter/material.dart';

import '../../domain/entities/customer_details.dart';

/// Review-step card showing the customer's contact details, with a "Change"
/// action that returns to the details form.
class OrderContactCard extends StatelessWidget {
  const OrderContactCard({
    super.key,
    required this.customer,
    required this.onChange,
  });

  final CustomerDetails customer;

  /// Called by the "Change" button; `null` disables it.
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Expanded rather than a Spacer so the heading wraps instead
                // of overflowing next to the button with very large text.
                Expanded(
                  child: Text(
                    'Contact details',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onChange,
                  child: const Text(
                    'Change',
                    semanticsLabel: 'Change contact details',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              customer.fullName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(customer.phone, style: bodyStyle),
            Text(customer.email, style: bodyStyle),
          ],
        ),
      ),
    );
  }
}
