import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/core/navigation/app_router.dart';
import 'package:payment_gateway/core/theme/app_theme.dart';
import 'package:payment_gateway/features/payment/domain/entities/checkout_result.dart';
import 'package:payment_gateway/features/payment/domain/entities/payment_order.dart';
import 'package:payment_gateway/features/payment/domain/repositories/payment_repository.dart';
import 'package:payment_gateway/features/payment/domain/services/payment_checkout.dart';
import 'package:payment_gateway/features/payment/domain/usecases/create_payment_order.dart';
import 'package:payment_gateway/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:payment_gateway/features/policy/domain/entities/policy.dart';
import 'package:payment_gateway/features/policy/domain/repositories/policy_repository.dart';
import 'package:payment_gateway/features/policy/domain/usecases/get_policy.dart';
import 'package:payment_gateway/features/policy/presentation/bloc/policy_bloc.dart';
import 'package:payment_gateway/features/policy/presentation/bloc/policy_event.dart';
import 'package:payment_gateway/features/policy/presentation/screens/policy_screen.dart';

const _individual3L = PolicyPlan(
  sumInsuredMinor: 30000000,
  premiumMinor: 396000,
);
const _family5L = PolicyPlan(sumInsuredMinor: 50000000, premiumMinor: 824000);
const _family10L = PolicyPlan(
  sumInsuredMinor: 100000000,
  premiumMinor: 1162000,
);

const _individual = CoverOption(
  id: 'individual',
  name: 'Individual',
  description: 'Covers one adult.',
  plans: [_individual3L],
);

const _family = CoverOption(
  id: 'family-floater',
  name: 'Family Floater',
  description: 'One sum insured shared by the family.',
  plans: [_family5L, _family10L],
);

const _policy = Policy(
  id: 'p1',
  name: 'Health Cover',
  insurer: 'Test Insurance',
  category: 'Health Insurance',
  termMonths: 12,
  coverOptions: [_individual, _family],
  inclusions: ['In-patient hospitalisation'],
  exclusions: ['Cosmetic procedures'],
);

class _FakePolicyRepository implements PolicyRepository {
  @override
  Future<Policy> getPolicy() async => _policy;
}

/// The backend: answers [createOrder] with [_createOrder].
class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository(this._createOrder);

  final Future<PaymentOrder> Function(int amountMinor) _createOrder;

  @override
  Future<PaymentOrder> createOrder(int amountMinor) =>
      _createOrder(amountMinor);
}

/// Razorpay Checkout: records what it was opened with and ends with
/// [result].
class _FakeCheckout implements PaymentCheckout {
  final result = Completer<CheckoutResult>();
  PaymentOrder? openedWith;
  String? description;

  @override
  Future<CheckoutResult> open(
    PaymentOrder order, {
    required String description,
  }) {
    openedWith = order;
    this.description = description;
    return result.future;
  }
}

/// A Razorpay order for [amountMinor], as the backend returns it.
PaymentOrder _order(int amountMinor) => PaymentOrder(
  orderId: 'order_123',
  amountMinor: amountMinor,
  currency: 'INR',
  keyId: 'rzp_test_key',
);

Future<void> _pumpPolicyScreen(
  WidgetTester tester, {
  Future<PaymentOrder> Function(int amountMinor)? createOrder,
  PaymentCheckout? checkout,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                PolicyBloc(GetPolicy(_FakePolicyRepository()))
                  ..add(const PolicyRequested()),
          ),
          BlocProvider(
            create: (_) => PaymentBloc(
              CreatePaymentOrder(
                _FakePaymentRepository(
                  createOrder ?? (amount) async => _order(amount),
                ),
              ),
              checkout ?? _FakeCheckout(),
            ),
          ),
        ],
        child: const PolicyScreen(),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the policy with the default cover selected', (
    tester,
  ) async {
    await _pumpPolicyScreen(tester);

    expect(find.text('Health Cover'), findsOneWidget);
    expect(find.text('Covers one adult.'), findsOneWidget);
    expect(find.text('In-patient hospitalisation'), findsOneWidget);
    expect(find.text('Cosmetic procedures'), findsOneWidget);
    expect(find.text('Premium for 1 year'), findsOneWidget);
    expect(find.text('₹3,960.00'), findsOneWidget);
  });

  testWidgets(
    'Add policy creates an order for the premium, opens Checkout with it, '
    'and shows the receipt once paid',
    (tester) async {
      int? orderedAmount;
      final checkout = _FakeCheckout();
      await _pumpPolicyScreen(
        tester,
        createOrder: (amount) async {
          orderedAmount = amount;
          return _order(amount);
        },
        checkout: checkout,
      );

      // Family Floater has no ₹3,00,000 plan, so its first plan is chosen.
      await _tapText(tester, 'Family Floater');
      await _tapText(tester, '₹10,00,000');
      expect(find.text('₹11,620.00'), findsOneWidget);

      await tester.tap(find.text('Add policy'));
      await tester.pump();

      expect(orderedAmount, 1162000);
      expect(checkout.openedWith, _order(1162000));
      expect(
        checkout.description,
        'Health Cover, Family Floater, ₹10,00,000 cover',
      );
      // Waiting for the customer in Checkout.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      checkout.result.complete(
        const CheckoutPaid(
          paymentId: 'pay_456',
          orderId: 'order_123',
          signature: 'signature',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment successful'), findsOneWidget);
      expect(find.text('order_123'), findsOneWidget);
      expect(find.text('pay_456'), findsOneWidget);
    },
  );

  testWidgets('closing Checkout without paying allows another try', (
    tester,
  ) async {
    final checkout = _FakeCheckout();
    await _pumpPolicyScreen(tester, checkout: checkout);

    await tester.tap(find.text('Add policy'));
    await tester.pump();
    checkout.result.complete(const CheckoutClosed());
    await tester.pumpAndSettle();

    expect(find.text('Payment cancelled.'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('a failed order request shows an error and allows a retry', (
    tester,
  ) async {
    await _pumpPolicyScreen(
      tester,
      createOrder: (_) async => throw Exception('offline'),
    );

    await tester.tap(find.text('Add policy'));
    await tester.pumpAndSettle();

    expect(find.text(PaymentBloc.errorMessage), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('fits a small phone with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpPolicyScreen(tester);

    // Layout overflows would have failed the test while pumping.
    expect(find.text('Add policy'), findsOneWidget);
  });
}
