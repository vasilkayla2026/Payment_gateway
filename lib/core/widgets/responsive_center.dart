import 'package:flutter/widgets.dart';

import '../theme/app_layout.dart';

/// Centres [child] horizontally and caps its width so pages stay readable on
/// wide screens. Takes the height of its child, so it is safe both inside
/// scroll views and in bottom bars.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    this.maxWidth = AppLayout.maxContentWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
