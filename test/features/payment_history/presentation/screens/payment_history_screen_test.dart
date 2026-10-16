import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/core/di/di.dart';
import 'package:payment_gateway/core/navigation/app_router.dart';
import 'package:payment_gateway/core/theme/app_theme.dart';
import 'package:payment_gateway/core/widgets/app_shell.dart';
import 'package:payment_gateway/features/payment_history/domain/entities/payment_record.dart';
import 'package:payment_gateway/features/payment_history/domain/repositories/payment_history_repository.dart';
import 'package:payment_gateway/features/payment_history/domain/usecases/get_payment_history.dart';
import 'package:payment_gateway/features/payment_history/presentation/bloc/payment_history_bloc.dart';
import 'package:payment_gateway/features/payment_history/presentation/bloc/payment_history_event.dart';
import 'package:payment_gateway/features/payment_history/presentation/screens/payment_history_screen.dart';

final _paid = PaymentRecord(
  orderId: 'order_1',
  amountMinor: 824000,
  status: PaymentRecordStatus.paid,
  paymentId: 'pay_1',
  createdAt: DateTime(2026, 10, 16, 14, 38),
);

final _pending = PaymentRecord(
  orderId: 'order_2',
  amountMinor: 396000,
  status: PaymentRecordStatus.pending,
  createdAt: DateTime(2026, 10, 16, 12, 10),
);

final _failed = PaymentRecord(
  orderId: 'order_3',
  amountMinor: 1162000,
  status: PaymentRecordStatus.failed,
  createdAt: DateTime(2026, 10, 15, 9, 5),
);

/// The backend: answers each load with [_load].
class _FakePaymentHistoryRepository implements PaymentHistoryRepository {
  _FakePaymentHistoryRepository(this._load);

  final Future<List<PaymentRecord>> Function() _load;

  @override
  Future<List<PaymentRecord>> getPaymentHistory() => _load();
}

PaymentHistoryBloc _bloc(Future<List<PaymentRecord>> Function() load) =>
    PaymentHistoryBloc(GetPaymentHistory(_FakePaymentHistoryRepository(load)));

Future<void> _pumpHistory(
  WidgetTester tester,
  Future<List<PaymentRecord>> Function() load,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider(
        create: (_) => _bloc(load)..add(const PaymentHistoryRequested()),
        child: const PaymentHistoryScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists each order with its time, reference, amount and status', (
    tester,
  ) async {
    await _pumpHistory(tester, () async => [_paid, _pending, _failed]);

    expect(find.text('16 Oct 2026, 2:38 PM'), findsOneWidget);
    expect(find.text('₹8,240.00'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    // A paid order shows the payment's reference, the others the order's.
    expect(find.text('pay_1'), findsOneWidget);
    expect(find.text('order_1'), findsNothing);
    expect(find.text('order_2'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('says so when there are no payments yet', (tester) async {
    await _pumpHistory(tester, () async => []);

    expect(find.text('No payments yet'), findsOneWidget);
  });

  testWidgets('a failed load shows an error that Try again recovers from', (
    tester,
  ) async {
    var fail = true;
    await _pumpHistory(tester, () async {
      if (fail) throw Exception('offline');
      return [_paid];
    });

    expect(find.text(PaymentHistoryBloc.errorMessage), findsOneWidget);

    fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text(PaymentHistoryBloc.errorMessage), findsNothing);
    expect(find.text('₹8,240.00'), findsOneWidget);
  });

  testWidgets('Refresh keeps the list on screen until the new one arrives', (
    tester,
  ) async {
    final reload = Completer<List<PaymentRecord>>();
    var loads = 0;
    await _pumpHistory(
      tester,
      () => ++loads == 1 ? Future.value([_pending]) : reload.future,
    );

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();

    expect(find.text('Pending'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // The webhook has confirmed the payment in the meantime.
    reload.complete([
      PaymentRecord(
        orderId: _pending.orderId,
        amountMinor: _pending.amountMinor,
        status: PaymentRecordStatus.paid,
        paymentId: 'pay_2',
        createdAt: _pending.createdAt,
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Pending'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('the sidebar opens the payment history', (tester) async {
    sl.registerFactory<PaymentHistoryBloc>(() => _bloc(() async => [_paid]));
    addTearDown(sl.reset);
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AppShell(title: 'Policy page', body: SizedBox()),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.tap(find.text('Payment History'));
    await tester.pumpAndSettle();

    expect(find.text('₹8,240.00'), findsOneWidget);
    // The page's title and its sidebar item.
    expect(find.text('Payment History'), findsNWidgets(2));
  });

  testWidgets('fits a small phone with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpHistory(tester, () async => [_failed, _pending, _paid]);

    // Layout overflows would have failed the test while pumping.
    expect(find.text('Failed'), findsOneWidget);
  });
}
