# payment_gateway

A simple single-product store with no login:

1. **Product page**: pick a colour and quantity, tap **Buy now**.
2. **Contact details**: name, email and mobile number, tap **Continue**.
3. **Review order**: item, contact details and price breakdown, tap **Proceed to pay**.
4. `PaymentBloc` sends the total to the backend, which creates the payment-gateway order
   and returns its id. For now the review screen only shows that id; opening the gateway
   checkout with it is the next step (see [Payment](#payment)).

## Run

```sh
flutter pub get
flutter run            # any device: Android, iOS, web, Windows
flutter analyze
flutter test
```

## Architecture

Feature-first Clean Architecture with `flutter_bloc`, `equatable` and `get_it`.

```
lib/
  main.dart                 init DI, run ShopApp
  app.dart                  ShopApp: CheckoutBloc above MaterialApp, themes, router
  core/
    client/api_client.dart  Dio client for the backend
    config/app_config.dart  backend URL, currency (INR), delivery fee, free-delivery threshold
    di/di.dart              composition root (sl = GetIt.instance)
    navigation/             route names + route table
    theme/  utils/  widgets/   feature-agnostic UI building blocks
  features/
    product/   domain (Product, GetProduct) · data (local JSON data source) · presentation (ProductBloc, product page)
    checkout/  domain (OrderItem, CustomerDetails, PriceBreakdown, CalculatePriceBreakdown) · presentation (CheckoutBloc, form, review, confirmation)
    payment/   domain (PaymentRepository, CreateOrderId) · data (PaymentRepositoryImpl: backend call) · presentation (PaymentBloc)
```

`CheckoutBloc` sits above the navigator and holds the item, prices and contact details
across the checkout screens. `PaymentBloc` is created for each visit to the review screen
and handles only the payment.

Dependency rules:

- **domain** is pure Dart and depends only on domain code.
- **data** and **presentation** depend inwards on domain, never on each other.
- Features reach other features only through their domain or BLoC; screens navigate by route name.
- **core** does not depend on features, except the DI and navigation composition roots.

Money is always an `int` in minor units (paise): `249900` = ₹2,499.00. It is only turned
into a decimal for display, in `core/utils/money_formatter.dart`.

## Payment

Set your backend in `AppConfig.baseUrl` (`lib/core/config/app_config.dart`).

**Proceed to pay** sends `POST /request/orderId` with `{"amount": 254800}` (the amount
in paise) and expects `{"orderId": "..."}` back. If your backend replies in another
shape, change `PaymentRepositoryImpl`. Debug builds print every request and response
to the console. While the request runs, the button shows a spinner and back
navigation is blocked. If it fails, the review screen shows an error and the customer
can try again.

Still to do, all in the app:

1. Open the gateway checkout (for example `razorpay_flutter`) with the order id,
   where the review screen now only shows it.
2. On success, open `AppRoutes.orderSuccess` with
   `OrderSuccessArgs(orderId: ..., transactionId: ...)` as the route arguments.

Before going live:

- Have the backend work out the amount from the product and quantity. Anyone can change
  an amount the app sends.
- Verify the payment signature on the backend before treating an order as paid.
- Keep API secrets on the backend; the app should hold only the gateway's public key.

To change the currency or delivery policy, edit `lib/core/config/app_config.dart`.
The product comes from `lib/features/product/data/datasources/product_local_data_source.dart`.
