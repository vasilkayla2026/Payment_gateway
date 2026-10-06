import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/features/checkout/domain/entities/customer_details.dart';
import 'package:payment_gateway/features/checkout/domain/entities/order_item.dart';
import 'package:payment_gateway/features/checkout/domain/usecases/calculate_price_breakdown.dart';
import 'package:payment_gateway/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:payment_gateway/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:payment_gateway/features/checkout/presentation/screens/order_summary_screen.dart';
import 'package:payment_gateway/features/payment/domain/repositories/payment_repository.dart';
import 'package:payment_gateway/features/payment/domain/usecases/create_order_id.dart';
import 'package:payment_gateway/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:payment_gateway/features/product/domain/entities/product.dart';

const _black = ProductColor(name: 'Black', argb: 0xFF000000);

/// ₹2,499.00 + ₹49.00 delivery = ₹2,548.00.
const _item = OrderItem(
  product: Product(
    id: 'p1',
    name: 'Headphones',
    tagline: '',
    description: '',
    priceMinor: 249900,
    highlights: [],
    colors: [_black],
    maxQuantityPerOrder: 5,
  ),
  color: _black,
  quantity: 1,
);

const _customer = CustomerDetails(
  fullName: 'Asha Rao',
  email: 'asha@example.com',
  phone: '9876543210',
);

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository(this._createOrderId);

  final Future<String> Function(int amountMinor) _createOrderId;

  @override
  Future<String> createOrderId(int amountMinor) => _createOrderId(amountMinor);
}

Future<void> _pumpReviewScreen(
  WidgetTester tester,
  PaymentRepository repository,
) async {
  final checkoutBloc =
      CheckoutBloc(
          const CalculatePriceBreakdown(
            deliveryFeeMinor: 4900,
            freeDeliveryThresholdMinor: 500000,
          ),
        )
        ..add(const CheckoutStarted(_item))
        ..add(const CheckoutCustomerDetailsSubmitted(_customer));
  addTearDown(checkoutBloc.close);

  await tester.pumpWidget(
    MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: checkoutBloc),
          BlocProvider(create: (_) => PaymentBloc(CreateOrderId(repository))),
        ],
        child: const OrderSummaryScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Proceed to pay sends the total and shows the order id', (
    tester,
  ) async {
    final orderId = Completer<String>();
    int? sentAmount;
    await _pumpReviewScreen(
      tester,
      _FakePaymentRepository((amountMinor) {
        sentAmount = amountMinor;
        return orderId.future;
      }),
    );

    await tester.tap(find.text('Proceed to pay'));
    await tester.pump();

    expect(sentAmount, 254800);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    orderId.complete('order_123');
    await tester.pumpAndSettle();

    expect(find.text('Order created: order_123'), findsOneWidget);
    expect(find.text('Proceed to pay'), findsOneWidget);
  });

  testWidgets('a failed request shows an error and allows a retry', (
    tester,
  ) async {
    await _pumpReviewScreen(
      tester,
      _FakePaymentRepository((_) async => throw Exception('offline')),
    );

    await tester.tap(find.text('Proceed to pay'));
    await tester.pumpAndSettle();

    expect(find.text(PaymentBloc.errorMessage), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
