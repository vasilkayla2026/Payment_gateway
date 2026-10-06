import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../config/app_config.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: AppConfig.locale,
  name: AppConfig.currencyCode,
  symbol: AppConfig.currencySymbol,
  decimalDigits: AppConfig.currencyDecimalDigits,
);

final num _minorUnitsPerMajor = math.pow(10, AppConfig.currencyDecimalDigits);

/// Formats an amount held in minor units (paise, cents) for display,
/// e.g. `249900` → `₹2,499.00`.
///
/// Amounts are always stored and calculated as integer minor units; this is
/// the only place they become fractional, and only for display.
String formatMoney(int minorUnits) =>
    _currencyFormat.format(minorUnits / _minorUnitsPerMajor);
