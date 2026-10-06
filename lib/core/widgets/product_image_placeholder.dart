import 'package:flutter/material.dart';

/// Stand-in for a product photo: a bag icon on a gradient tinted with
/// [color]. Fills the space its parent gives it, so wrap it in an
/// [AspectRatio] or [SizedBox].
class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    super.key,
    required this.color,
    required this.semanticLabel,
    this.borderRadius = 24,
  });

  final Color color;

  /// Read by screen readers, e.g. "Wireless Headphones, Ocean Blue".
  final String semanticLabel;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(color, Colors.white, 0.3)!, color],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag_rounded,
                size: side.isFinite ? side * 0.45 : 96,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
