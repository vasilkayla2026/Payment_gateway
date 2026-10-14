/// Formats a length of time held in months, in years when it divides evenly:
/// `12` → `1 year`, `24` → `2 years`, `6` → `6 months`.
String formatMonths(int months) {
  if (months > 0 && months % 12 == 0) {
    final years = months ~/ 12;
    return years == 1 ? '1 year' : '$years years';
  }
  return months == 1 ? '1 month' : '$months months';
}
