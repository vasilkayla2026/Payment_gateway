import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/core/navigation/app_router.dart';
import 'package:payment_gateway/core/theme/app_theme.dart';
import 'package:payment_gateway/core/widgets/app_shell.dart';

/// A stand-in for the policy page, which is the app's first route, on a
/// screen of [size].
Future<void> _pumpHome(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: const AppShell(title: 'Policy page', body: SizedBox()),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}

const _tablet = Size(1024, 900);
const _phone = Size(390, 844);

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('on wide screens the sidebar shows without a menu button', (
    tester,
  ) async {
    await _pumpHome(tester, _tablet);

    expect(find.byTooltip('Open navigation menu'), findsNothing);
    for (final label in [
      'Dashboard',
      'Payment History',
      'My Team',
      'Attendance',
      'Leave',
      'Holidays',
      'Approvals',
      'Ticketing',
      'Pay slip',
      'Claim',
      'Documents',
      'My Assets',
      'Profile',
      'Log Out',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('other destinations open a "No data" page; Dashboard returns', (
    tester,
  ) async {
    await _pumpHome(tester, _tablet);
    await _tapText(tester, 'My Team');

    expect(find.text('My Team Members'), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);
    // Still beside the page, and no back button, as in ESS.
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await _tapText(tester, 'Dashboard');

    expect(find.text('Policy page'), findsOneWidget);
    expect(find.text('No data'), findsNothing);
  });

  testWidgets('Approvals opens to its own destinations', (tester) async {
    await _pumpHome(tester, _tablet);
    await _tapText(tester, 'Approvals');
    // The group's Claim comes before the top-level one.
    await tester.tap(find.text('Claim').first);
    await tester.pumpAndSettle();

    expect(find.text('Claim Approvals'), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('on phones the sidebar is a drawer behind the menu button', (
    tester,
  ) async {
    await _pumpHome(tester, _phone);

    expect(find.text('Dashboard'), findsNothing);

    await _openDrawer(tester);
    await _tapText(tester, 'Leave');

    expect(find.text('No data'), findsOneWidget);
    // The drawer closed on the way.
    expect(find.text('Dashboard'), findsNothing);

    await _openDrawer(tester);
    await _tapText(tester, 'Dashboard');

    expect(find.text('Policy page'), findsOneWidget);
  });
}
