import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/period_formatter.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_event.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../../domain/entities/policy.dart';
import '../../domain/entities/policy_quote.dart';
import '../bloc/policy_bloc.dart';
import '../bloc/policy_event.dart';
import '../bloc/policy_state.dart';
import '../widgets/choice_pills.dart';
import '../widgets/coverage_list.dart';

/// Home screen: the policy with its cover and sum insured pickers. "Add
/// policy" pays the premium through Razorpay, then shows the receipt. Back
/// navigation and the pickers are blocked while the payment runs.
class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onPaymentStatusChanged,
      child: BlocBuilder<PolicyBloc, PolicyState>(
        builder: (context, state) {
          final quote = state.status == PolicyStatus.loaded
              ? state.quote
              : null;
          final isPaying = context.watch<PaymentBloc>().state.isLoading;

          return PopScope(
            canPop: !isPaying,
            child: AppShell(
              title: AppConfig.appName,
              body: switch (state.status) {
                PolicyStatus.failure => _PolicyFailure(
                  message: state.error ?? 'Could not load the policy.',
                ),
                _ when quote != null => _PolicyContent(
                  quote: quote,
                  enabled: !isPaying,
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
              bottomNavigationBar: quote == null
                  ? null
                  : _AddPolicyBar(quote: quote, isLoading: isPaying),
            ),
          );
        },
      ),
    );
  }

  void _onPaymentStatusChanged(BuildContext context, PaymentState state) {
    switch (state.status) {
      case PaymentStatus.paid:
        // The pickers were locked during the payment, so this is the quote
        // that was paid for.
        final quote = context.read<PolicyBloc>().state.quote;
        if (quote == null) return;
        Navigator.of(context).pushNamed(
          AppRoutes.orderSuccess,
          arguments: OrderSuccessArgs(
            orderId: state.orderId!,
            transactionId: state.paymentId!,
            quote: quote,
          ),
        );
      case PaymentStatus.cancelled:
        _showMessage(context, 'Payment cancelled.');
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

class _PolicyFailure extends StatelessWidget {
  const _PolicyFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  context.read<PolicyBloc>().add(const PolicyRequested()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent({required this.quote, required this.enabled});

  final PolicyQuote quote;

  /// Whether the cover and sum insured can be changed.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policy = quote.policy;
    final bloc = context.read<PolicyBloc>();

    // Fills the width beside the sidebar.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppLayout.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          _PolicyHeader(policy: policy),
          _Section(
            title: 'Who would you like to cover?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                ChoicePills<CoverOption>(
                  options: policy.coverOptions,
                  selected: quote.cover,
                  labelOf: (cover) => cover.name,
                  onSelected: (cover) => bloc.add(PolicyCoverSelected(cover)),
                  enabled: enabled,
                ),
                Text(
                  quote.cover.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _Section(
            title: 'How much coverage do you need?',
            child: ChoicePills<PolicyPlan>(
              options: quote.cover.plans,
              selected: quote.plan,
              labelOf: (plan) => formatMoneyWhole(plan.sumInsuredMinor),
              onSelected: (plan) => bloc.add(PolicyPlanSelected(plan)),
              enabled: enabled,
            ),
          ),
          if (policy.inclusions.isNotEmpty || policy.exclusions.isNotEmpty)
            _CoverageCard(policy: policy),
        ],
      ),
    );
  }
}

/// The policy's name, insurer and line of insurance.
class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader({required this.policy});

  final Policy policy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.cardYellow,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: SizedBox.square(
                dimension: 48,
                child: Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(policy.name, style: textTheme.titleLarge),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${policy.insurer} · ${policy.category}',
                    style: textTheme.bodyMedium,
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

/// What the policy covers and excludes, in one card as on the ADSL policy
/// details screen.
class _CoverageCard extends StatelessWidget {
  const _CoverageCard({required this.policy});

  final Policy policy;

  @override
  Widget build(BuildContext context) {
    final inclusions = policy.inclusions;
    final exclusions = policy.exclusions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (inclusions.isNotEmpty)
              _Section(
                title: "What's covered",
                child: CoverageList(items: inclusions, covered: true),
              ),
            if (inclusions.isNotEmpty && exclusions.isNotEmpty)
              const Divider(height: 32),
            if (exclusions.isNotEmpty)
              _Section(
                title: "What's not covered",
                child: CoverageList(items: exclusions, covered: false),
              ),
          ],
        ),
      ),
    );
  }
}

/// A headed block of the page.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        child,
      ],
    );
  }
}

/// Premium for the chosen cover and "Add policy", which pays it.
class _AddPolicyBar extends StatelessWidget {
  const _AddPolicyBar({required this.quote, required this.isLoading});

  final PolicyQuote quote;
  final bool isLoading;

  void _addPolicy(BuildContext context) {
    final quote = context.read<PolicyBloc>().state.quote;
    if (quote == null) return;
    context.read<PaymentBloc>().add(
      PaymentRequested(
        quote.premiumMinor,
        // Shown in Razorpay Checkout.
        description:
            '${quote.policy.name}, ${quote.cover.name}, '
            '${formatMoneyWhole(quote.plan.sumInsuredMinor)} cover',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      maxWidth: double.infinity,
      label: 'Premium for ${formatMonths(quote.policy.termMonths)}',
      value: formatMoney(quote.premiumMinor),
      action: FilledButton(
        onPressed: isLoading ? null : () => _addPolicy(context),
        child: isLoading
            ? Semantics(
                label: 'Processing payment',
                child: const SizedBox.square(
                  dimension: 22,
                  // Navy, as on the ESS buttons; the default yellow would not
                  // show on the yellow button.
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textDark,
                  ),
                ),
              )
            : const Text('Add policy'),
      ),
    );
  }
}
