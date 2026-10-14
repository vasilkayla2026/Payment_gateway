// Razorpay Checkout runs through checkout.js, so it only exists on the web;
// other platforms get a stand-in that reports it as unavailable.
export 'razorpay_checkout_stub.dart'
    if (dart.library.js_interop) 'razorpay_checkout_web.dart';
