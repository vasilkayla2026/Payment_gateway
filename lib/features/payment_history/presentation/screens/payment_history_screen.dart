import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../domain/entities/payment_record.dart';
import '../bloc/payment_history_bloc.dart';
import '../bloc/payment_history_event.dart';
import '../bloc/payment_history_state.dart';
import '../widgets/payment_record_card.dart';

/// Sidebar destination listing past orders, newest first, with how each
/// payment went. Refresh reloads them, e.g. once the webhook has confirmed a
/// pending payment.
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
      builder: (context, state) {
        final records = state.records;

        return AppShell(
          title: 'Payment History',
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: state.isLoading ? null : () => _reload(context),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: switch (state.status) {
            PaymentHistoryStatus.failure => _HistoryFailure(
              message: state.error ?? PaymentHistoryBloc.errorMessage,
            ),
            _ when records.isNotEmpty => _HistoryList(
              records: records,
              isRefreshing: state.isLoading,
            ),
            PaymentHistoryStatus.loaded => const _NoPayments(),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

void _reload(BuildContext context) =>
    context.read<PaymentHistoryBloc>().add(const PaymentHistoryRequested());

/// The records as cards, with a progress bar along the top while a refresh
/// loads.
class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.records, required this.isRefreshing});

  final List<PaymentRecord> records;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(AppLayout.pagePadding),
          itemCount: records.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) => ResponsiveCenter(
            maxWidth: AppLayout.formMaxWidth,
            child: PaymentRecordCard(record: records[index]),
          ),
        ),
        if (isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(semanticsLabel: 'Refreshing'),
          ),
      ],
    );
  }
}

/// The ESS empty state, as on the pages without content.
class _NoPayments extends StatelessWidget {
  const _NoPayments();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textGrey,
          ),
          SizedBox(height: 12),
          Text(
            'No payments yet',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryFailure extends StatelessWidget {
  const _HistoryFailure({required this.message});

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
              onPressed: () => _reload(context),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
