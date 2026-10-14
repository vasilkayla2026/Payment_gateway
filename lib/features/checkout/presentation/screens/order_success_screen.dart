import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../widgets/order_receipt_card.dart';

/// Shown after a successful payment with the policy and the payment
/// references. "Done" returns to the policy page.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, this.args});

  /// `null` if the route was opened without a completed payment.
  final OrderSuccessArgs? args;

  @override
  Widget build(BuildContext context) {
    final args = this.args;
    if (args == null) return const _NoRecentPurchaseView();

    final theme = Theme.of(context);
    final quote = args.quote;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase complete'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.pagePadding),
        child: ResponsiveCenter(
          maxWidth: AppLayout.formMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const ExcludeSemantics(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 88,
                  color: AppColors.presentText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment successful',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you! Your payment for ${quote.policy.name} is '
                'complete.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              OrderReceiptCard(
                orderId: args.orderId,
                transactionId: args.transactionId,
                quote: quote,
                amountMinor: quote.premiumMinor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomActionBar(
        maxWidth: AppLayout.formMaxWidth,
        action: _DoneButton(),
      ),
    );
  }
}

/// Shown if the screen is reached without a completed payment.
class _NoRecentPurchaseView extends StatelessWidget {
  const _NoRecentPurchaseView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase complete'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.pagePadding),
          child: Text('No recent purchase.', textAlign: TextAlign.center),
        ),
      ),
      bottomNavigationBar: const BottomActionBar(
        maxWidth: AppLayout.formMaxWidth,
        action: _DoneButton(),
      ),
    );
  }
}

/// Back to the policy page.
class _DoneButton extends StatelessWidget {
  const _DoneButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: const Text('Done'),
    );
  }
}
