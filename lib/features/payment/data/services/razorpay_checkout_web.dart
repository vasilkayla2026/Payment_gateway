import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/checkout_result.dart';
import '../../domain/entities/payment_order.dart';
import '../../domain/services/payment_checkout.dart';

/// `openRazorpay` in web/index.html: `new Razorpay(options).open()`.
@JS('openRazorpay')
external void _openRazorpay(JSObject options);

/// Razorpay Standard Checkout through checkout.js, as in the DAYBUS agency
/// app. The options are those of Razorpay's web integration guide.
class RazorpayCheckout implements PaymentCheckout {
  const RazorpayCheckout();

  @override
  Future<CheckoutResult> open(
    PaymentOrder order, {
    required String description,
  }) {
    final result = Completer<CheckoutResult>();

    final modal = JSObject()
      // The customer closed Checkout without paying.
      ..['ondismiss'] = (() {
        if (!result.isCompleted) result.complete(const CheckoutClosed());
      }).toJS;

    final options = JSObject()
      ..['key'] = order.keyId.toJS
      ..['order_id'] = order.orderId.toJS
      ..['amount'] = order.amountMinor.toJS
      ..['currency'] = order.currency.toJS
      ..['name'] = AppConfig.appName.toJS
      ..['description'] = description.toJS
      ..['theme'] = (JSObject()..['color'] = '#FDCB03'.toJS)
      ..['modal'] = modal
      // The customer paid; Checkout passes the payment's ids.
      ..['handler'] = ((JSObject response) {
        if (result.isCompleted) return;
        result.complete(
          CheckoutPaid(
            paymentId: _text(response, 'razorpay_payment_id'),
            orderId: _text(response, 'razorpay_order_id'),
            signature: _text(response, 'razorpay_signature'),
          ),
        );
      }).toJS;

    _openRazorpay(options);
    return result.future;
  }

  static String _text(JSObject object, String key) =>
      (object[key] as JSString?)?.toDart ?? '';
}
