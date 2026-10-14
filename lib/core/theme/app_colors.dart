import 'package:flutter/painting.dart';

/// The ADSL ESS app's palette: a warm primary yellow, deep-navy text and
/// soft grey surfaces. `AppTheme` maps it onto the colour scheme; widgets
/// use these directly only where the scheme has no matching role.
abstract final class AppColors {
  static const Color primaryYellow = Color(0xFFFDCB03);
  static const Color screenBackground = Color(0xFFF3F4F6);
  static const Color textDark = Color(0xFF0A2649);
  static const Color textGrey = Color(0xFF8E8E8E);
  static const Color subtleGrey = Color(0xFFF1F4F9);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color cardYellow = Color(0xFFFFF9E5);

  // Status colours
  static const Color presentText = Color(0xFF52C41A);
  static const Color absentText = Color(0xFFE25C5C);
}
