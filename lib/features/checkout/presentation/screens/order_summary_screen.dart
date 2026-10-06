import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_event.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../bloc/checkout_bloc.dart';
import '../widgets/order_contact_card.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_price_details_card.dart';

/// Checkout step 3: review the item, contact details and amounts, then
/// "Proceed to pay". Back navigation is blocked while the payment starts.
class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutBloc>().state;
    final item = checkout.item;
    final pricing = checkout.pricing;
    final customer = checkout.customer;
    if (item == null || pricing == null || customer == null) {
      return const _MissingDetailsView();
    }

    return BlocConsumer<PaymentBloc, PaymentState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onPaymentStatusChanged,
      builder: (context, payment) {
        return PopScope(
          canPop: !payment.isLoading,
          child: Scaffold(
            appBar: AppBar(title: const Text('Review order')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppLayout.pagePadding),
              child: ResponsiveCenter(
                maxWidth: AppLayout.formMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OrderItemCard(item: item),
                    const SizedBox(height: 16),
                    OrderContactCard(
                      customer: customer,
                      onChange: payment.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 16),
                    OrderPriceDetailsCard(pricing: pricing),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomActionBar(
              maxWidth: AppLayout.formMaxWidth,
              label: 'Total',
              value: formatMoney(pricing.totalMinor),
              action: _ProceedToPayButton(
                amountMinor: pricing.totalMinor,
                isLoading: payment.isLoading,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPaymentStatusChanged(BuildContext context, PaymentState state) {
    switch (state.status) {
      case PaymentStatus.orderCreated:
        // Next step: open the gateway checkout with state.orderId.
        _showMessage(context, 'Order created: ${state.orderId}');
      case PaymentStatus.failure:
        _showMessage(context, state.error ?? PaymentBloc.errorMessage);
      case PaymentStatus.initial:
      case PaymentStatus.loading:
        break;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Shown only if the screen is reached without an item or contact details.
class _MissingDetailsView extends StatelessWidget {
  const _MissingDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review order')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.pagePadding),
          child: Text(
            'Add your contact details first.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ProceedToPayButton extends StatelessWidget {
  const _ProceedToPayButton({
    required this.amountMinor,
    required this.isLoading,
  });

  final int amountMinor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading
          ? null
          : () =>
                context.read<PaymentBloc>().add(PaymentRequested(amountMinor)),
      child: isLoading
          ? Semantics(
              label: 'Processing payment',
              child: const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : const Text('Proceed to pay'),
    );
  }
}
