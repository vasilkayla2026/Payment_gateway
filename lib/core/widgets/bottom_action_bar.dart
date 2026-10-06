import 'package:flutter/material.dart';

import '../theme/app_layout.dart';
import 'responsive_center.dart';

/// Bar pinned to the bottom of a screen holding its primary action,
/// optionally preceded by a caption/value pair such as "Total ₹2,548.00".
///
/// Use it as [Scaffold.bottomNavigationBar].
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.action,
    this.label,
    this.value,
    this.maxWidth = AppLayout.maxContentWidth,
  });

  /// Below this width (in unscaled text units) the value goes above the
  /// action instead of beside it, so the button label is not squeezed on
  /// narrow screens or with large text.
  static const double _stackBelowWidth = 300;

  /// The primary button, typically a [FilledButton]; it fills the width left
  /// over by [value].
  final Widget action;

  /// Caption shown above [value], e.g. "Total". Ignored without [value].
  final String? label;

  /// Emphasised value, e.g. a formatted amount.
  final String? value;

  /// Matches the width of the page content above the bar.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(
          horizontal: AppLayout.pagePadding,
          vertical: 12,
        ),
        child: ResponsiveCenter(
          maxWidth: maxWidth,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (value == null) {
                return SizedBox(width: double.infinity, child: action);
              }
              final summary = _Summary(label: label, value: value);
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              if (constraints.maxWidth / textScale < _stackBelowWidth) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [summary, const SizedBox(height: 12), action],
                );
              }
              return Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.45,
                    ),
                    child: summary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: action),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Caption over an emphasised value that shrinks rather than overflows.
class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = this.label;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
