import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/payment_record.dart';

/// One order of the payment history, laid out like a statement line: when
/// and its reference on the left, the amount and how the payment went on
/// the right.
class PaymentRecordCard extends StatelessWidget {
  const PaymentRecordCard({super.key, required this.record});

  final PaymentRecord record;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    formatDateTime(record.createdAt),
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // The payment's reference once paid, else the order's;
                  // selectable, so the customer can quote it.
                  SelectableText(
                    record.paymentId ?? record.orderId,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              // Shrinks rather than wraps on narrow screens.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.topEnd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 6,
                  children: [
                    Text(
                      formatMoney(record.amountMinor),
                      style: textTheme.titleLarge,
                    ),
                    _StatusPill(status: record.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Paid", "Failed" or "Pending" on a tint of its status colour.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final PaymentRecordStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      PaymentRecordStatus.paid => ('Paid', AppColors.presentText),
      PaymentRecordStatus.failed => ('Failed', AppColors.absentText),
      PaymentRecordStatus.pending => ('Pending', AppColors.pendingText),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
