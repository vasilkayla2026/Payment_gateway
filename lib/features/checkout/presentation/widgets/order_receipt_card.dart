import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../../policy/domain/entities/policy_quote.dart';

/// Confirmation-step card listing the references and amount of a paid
/// order, and the policy it paid for.
class OrderReceiptCard extends StatelessWidget {
  const OrderReceiptCard({
    super.key,
    required this.orderId,
    required this.transactionId,
    required this.quote,
    required this.amountMinor,
  });

  /// The gateway order id.
  final String orderId;

  /// The gateway's payment reference.
  final String transactionId;

  final PolicyQuote quote;
  final int amountMinor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReceiptRow(label: 'Order ID', value: orderId),
            const SizedBox(height: 12),
            _ReceiptRow(
              label: 'Transaction ID',
              value: transactionId,
              selectable: true,
            ),
            const SizedBox(height: 12),
            _ReceiptRow(label: 'Amount paid', value: formatMoney(amountMinor)),
            const SizedBox(height: 12),
            _ReceiptRow(label: 'Policy', value: quote.policy.name),
            const SizedBox(height: 12),
            _ReceiptRow(
              label: 'Cover',
              value:
                  '${quote.cover.name}, '
                  '${formatMoneyWhole(quote.plan.sumInsuredMinor)} sum insured',
            ),
          ],
        ),
      ),
    );
  }
}

/// Label on the left, value on the right; both wrap so long values never
/// overflow.
class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;

  /// Lets the customer copy the value, e.g. a payment reference.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: selectable
              ? SelectableText(
                  value,
                  textAlign: TextAlign.end,
                  style: valueStyle,
                )
              : Text(value, textAlign: TextAlign.end, style: valueStyle),
        ),
      ],
    );
  }
}
