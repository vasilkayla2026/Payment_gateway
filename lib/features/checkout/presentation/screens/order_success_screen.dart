import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../bloc/checkout_bloc.dart';
import '../widgets/order_receipt_card.dart';

/// Route arguments of `AppRoutes.orderSuccess`: the references of a
/// successful payment.
class OrderSuccessArgs {
  /// The gateway order id created by the backend.
  final String orderId;

  /// The gateway's payment reference.
  final String transactionId;

  const OrderSuccessArgs({required this.orderId, required this.transactionId});
}

/// Shown after a successful payment with the order and payment references.
/// "Continue shopping" returns to the product page.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, this.args});

  /// `null` if the route was opened without a completed payment.
  final OrderSuccessArgs? args;

  @override
  Widget build(BuildContext context) {
    final args = this.args;
    final checkout = context.watch<CheckoutBloc>().state;
    final item = checkout.item;
    final pricing = checkout.pricing;
    final customer = checkout.customer;
    if (args == null || item == null || pricing == null || customer == null) {
      return const _NoRecentOrderView();
    }

    final theme = Theme.of(context);
    final firstName = customer.fullName.trim().split(_whitespace).first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order confirmed'),
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
              ExcludeSemantics(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 88,
                  color: theme.colorScheme.primary,
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
                'Thank you, $firstName! Your order has been placed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              OrderReceiptCard(
                orderId: args.orderId,
                transactionId: args.transactionId,
                item: item,
                amountMinor: pricing.totalMinor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomActionBar(
        maxWidth: AppLayout.formMaxWidth,
        action: _ContinueShoppingButton(),
      ),
    );
  }

  static final RegExp _whitespace = RegExp(r'\s+');
}

/// Shown if the screen is reached without a completed payment.
class _NoRecentOrderView extends StatelessWidget {
  const _NoRecentOrderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.pagePadding),
          child: Text('No recent order.', textAlign: TextAlign.center),
        ),
      ),
      bottomNavigationBar: const BottomActionBar(
        maxWidth: AppLayout.formMaxWidth,
        action: _ContinueShoppingButton(),
      ),
    );
  }
}

class _ContinueShoppingButton extends StatelessWidget {
  const _ContinueShoppingButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: const Text('Continue shopping'),
    );
  }
}
