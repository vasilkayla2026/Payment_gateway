import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

/// Row of round colour swatches; the [selected] one is ringed and ticked.
class ColorSelector extends StatelessWidget {
  const ColorSelector({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<ProductColor> colors;
  final ProductColor selected;
  final ValueChanged<ProductColor> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in colors)
          _ColorSwatch(
            key: ValueKey('color-${color.name}'),
            color: color,
            isSelected: color == selected,
            onTap: () => onSelected(color),
          ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final ProductColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final swatch = Color(color.argb);
    // Swatch colours come from product data, so pick whichever tick colour
    // stays visible on this particular swatch.
    final checkColor =
        ThemeData.estimateBrightnessForColor(swatch) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Tooltip(
      message: color.name,
      // The Semantics label below already names the colour.
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        button: true,
        selected: isSelected,
        inMutuallyExclusiveGroup: true,
        label: color.name,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              // Ring around the swatch with a small gap; transparent when
              // unselected so the layout never shifts.
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: swatch,
                    // Keeps dark swatches visible on a dark surface.
                    border: isSelected
                        ? null
                        : Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, size: 20, color: checkColor)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
