/// App-wide settings. Change these to point the app at your backend or to
/// adapt it to another currency.
final class AppConfig {
  /// Backend that creates payment orders: payment_gateway_backend, run
  /// locally. Use its deployed URL in production.
  static const String baseUrl = 'https://coma-argue-carnival.ngrok-free.dev';
  static const String appName = 'Policy';

  /// ISO 4217 currency code handed to the payment gateway.
  static const String currencyCode = 'INR';
  static const String currencySymbol = '₹';

  /// Number of minor units per major unit is 10^[currencyDecimalDigits]
  /// (100 paise = 1 rupee).
  static const int currencyDecimalDigits = 2;

  /// Locale used for digit grouping, e.g. `en_IN` formats ₹1,00,000.00.
  static const String locale = 'en_IN';
}
