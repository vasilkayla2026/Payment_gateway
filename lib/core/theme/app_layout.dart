/// Shared spacing and width constraints.
abstract final class AppLayout {
  static const double pagePadding = 16;

  /// Maximum width of page content on tablets, desktop and web.
  static const double maxContentWidth = 960;

  /// Maximum width of forms and single-column summaries.
  static const double formMaxWidth = 640;

  /// Width from which the product page shows image and details side by side.
  static const double wideBreakpoint = 720;
}
