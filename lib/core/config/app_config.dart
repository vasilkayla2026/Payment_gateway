/// Store-wide settings. Change these to adapt the shop to another currency
/// or delivery policy; they are injected into the domain layer by `di.dart`.
final class AppConfig {
  /// Backend that creates payment orders, e.g. `https://api.example.com`.
  static const String baseUrl = '';
  static const String storeName = 'Simple Store';

  /// ISO 4217 currency code handed to the payment gateway.
  static const String currencyCode = 'INR';
  static const String currencySymbol = '₹';

  /// Number of minor units per major unit is 10^[currencyDecimalDigits]
  /// (100 paise = 1 rupee).
  static const int currencyDecimalDigits = 2;

  /// Locale used for digit grouping, e.g. `en_IN` formats ₹1,00,000.00.
  static const String locale = 'en_IN';

  /// Flat delivery fee in minor units (₹49.00).
  static const int deliveryFeeMinor = 4900;

  /// Orders whose item total reaches this amount ship free (₹5,000.00).
  static const int freeDeliveryThresholdMinor = 500000;
}
