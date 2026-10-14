import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// What a policy covers, ticked, or what it excludes, crossed; like the
/// "What's Covered" lists of the ADSL customer app.
class CoverageList extends StatelessWidget {
  const CoverageList({super.key, required this.items, required this.covered});

  final List<String> items;

  /// Whether [items] are covered (ticks) or excluded (crosses).
  final bool covered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final item in items) _CoverageRow(text: item, covered: covered),
      ],
    );
  }
}

class _CoverageRow extends StatelessWidget {
  const _CoverageRow({required this.text, required this.covered});

  final String text;
  final bool covered;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          covered ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 20,
          color: covered ? AppColors.presentText : AppColors.absentText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
