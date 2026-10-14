import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_shell.dart';

/// A sidebar destination this app has no content for: its title over the
/// ESS empty state.
class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: title,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.textGrey),
            SizedBox(height: 12),
            Text(
              'No data',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
