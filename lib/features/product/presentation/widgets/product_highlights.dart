import 'package:flutter/material.dart';

/// Ticked list of a product's key selling points.
class ProductHighlights extends StatelessWidget {
  const ProductHighlights({super.key, required this.highlights});

  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (final highlight in highlights) _HighlightRow(text: highlight),
      ],
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
