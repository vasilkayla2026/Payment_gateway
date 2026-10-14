import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../config/app_config.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: AppConfig.locale,
  name: AppConfig.currencyCode,
  symbol: AppConfig.currencySymbol,
  decimalDigits: AppConfig.currencyDecimalDigits,
);

final NumberFormat _wholeCurrencyFormat = NumberFormat.currency(
  locale: AppConfig.locale,
  name: AppConfig.currencyCode,
  symbol: AppConfig.currencySymbol,
  decimalDigits: 0,
);

final num _minorUnitsPerMajor = math.pow(10, AppConfig.currencyDecimalDigits);

/// Formats an amount held in minor units (paise, cents) for display,
/// e.g. `824000` → `₹8,240.00`.
///
/// Amounts are always stored and calculated as integer minor units; this is
/// the only place they become fractional, and only for display.
String formatMoney(int minorUnits) =>
    _currencyFormat.format(minorUnits / _minorUnitsPerMajor);

/// Like [formatMoney] but rounded to whole major units, e.g. `50000000` →
/// `₹5,00,000`. For amounts that are always whole, such as a sum insured.
String formatMoneyWhole(int minorUnits) =>
    _wholeCurrencyFormat.format(minorUnits / _minorUnitsPerMajor);
