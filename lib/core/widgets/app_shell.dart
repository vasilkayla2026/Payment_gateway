import 'package:flutter/material.dart';

import '../navigation/app_router.dart';
import '../theme/app_colors.dart';

/// A sidebar destination. When [children] is non-empty the item acts as an
/// expandable group header instead of a direct destination.
class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  /// The destination page's title; defaults to [label].
  final String? title;
  final List<_NavItem> children;

  const _NavItem(
    this.icon,
    this.label,
    this.route, {
    this.title,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;
}

/// The ADSL ESS app's menu. Dashboard is the policy page; every other
/// destination opens a "No data" page.
const List<_NavItem> _navItems = [
  _NavItem(Icons.grid_view_rounded, 'Dashboard', AppRoutes.policy),
  _NavItem(
    Icons.groups_2_outlined,
    'My Team',
    '/my-team',
    title: 'My Team Members',
  ),
  _NavItem(Icons.calendar_today_outlined, 'Attendance', '/attendance'),
  _NavItem(Icons.event_note_outlined, 'Leave', '/leave'),
  _NavItem(Icons.celebration_outlined, 'Holidays', '/holidays'),
  _NavItem(
    Icons.fact_check_outlined,
    'Approvals',
    '/approvals',
    children: [
      _NavItem(
        Icons.request_quote_outlined,
        'Claim',
        '/approvals/claim',
        title: 'Claim Approvals',
      ),
      _NavItem(
        Icons.calendar_today_outlined,
        'Attendance',
        '/approvals/attendance',
        title: 'Attendance Approvals',
      ),
      _NavItem(
        Icons.event_note_outlined,
        'Leave',
        '/approvals/leave',
        title: 'Leave Approvals',
      ),
    ],
  ),
  _NavItem(Icons.chat_bubble_outline, 'Ticketing', '/ticketing'),
  _NavItem(Icons.payments_outlined, 'Pay slip', '/pay-slip'),
  _NavItem(Icons.request_quote_outlined, 'Claim', '/claim', title: 'Claims'),
  _NavItem(
    Icons.description_outlined,
    'Documents',
    '/documents',
    title: 'Document',
  ),
  _NavItem(Icons.devices_other_outlined, 'My Assets', '/my-assets'),
  _NavItem(Icons.person_outline, 'Profile', '/profile'),
];

/// The ADSL ESS app's sidebar, as a drawer.
/// A top-level page in the ADSL ESS layout: the sidebar beside the page, or,
/// on phones, in a drawer behind the app bar's menu button.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
  });

  /// Below this width the sidebar would leave too little room for the page,
  /// so it moves into a drawer.
  static const double _sidebarMinWidth = 600;

  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < _sidebarMinWidth;
    final page = Scaffold(
      appBar: AppBar(
        title: Text(title),
        // The menu button on phones; beside the sidebar, nothing, as in ESS.
        automaticallyImplyLeading: isSmallScreen,
      ),
      drawer: isSmallScreen
          ? const Drawer(width: 220, child: _Sidebar())
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
    if (isSmallScreen) return page;

    return Row(
      children: [
        // Gives the sidebar's items somewhere to draw their ink.
        const Material(type: MaterialType.transparency, child: _Sidebar()),
        Expanded(child: page),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    void navigate(_NavItem item) {
      final navigator = Navigator.of(context);
      // Only in a drawer is there a Scaffold to close.
      Scaffold.maybeOf(context)?.closeDrawer();
      if (item.route == currentRoute) return;
      if (item.route == AppRoutes.policy) {
        navigator.popUntil((route) => route.isFirst);
      } else {
        // Keeps the policy page underneath, so back returns to it.
        navigator.pushNamedAndRemoveUntil(
          item.route,
          (route) => route.isFirst,
          arguments: item.title ?? item.label,
        );
      }
    }

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Image.asset(
              'assets/images/app_logo.png',
              height: 48,
              errorBuilder: (context, error, stack) => const _LogoFallback(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in _navItems)
                  if (item.hasChildren)
                    _SidebarGroup(
                      item: item,
                      currentRoute: currentRoute,
                      onNavigate: navigate,
                    )
                  else
                    _SidebarItem(
                      icon: item.icon,
                      label: item.label,
                      isActive: currentRoute == item.route,
                      onTap: () => navigate(item),
                    ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: _SidebarItem(
              icon: Icons.logout,
              label: 'Log Out',
              onTap: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  /// The ESS confirmation. This app has no sign-in, so confirming only
  /// closes the dialog.
  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE11D48),
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You will need to sign in again to access your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'ADSL',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: 1,
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryYellow
                  : (_hovered ? AppColors.cardYellow : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 19,
                  color: active ? AppColors.textDark : AppColors.textGrey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active || _hovered
                          ? AppColors.textDark
                          : AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An expandable sidebar group: a header row that toggles a list of indented
/// child destinations. Opens by itself while one of its children is the
/// current page.
class _SidebarGroup extends StatefulWidget {
  final _NavItem item;
  final String? currentRoute;
  final void Function(_NavItem item) onNavigate;

  const _SidebarGroup({
    required this.item,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<_SidebarGroup> createState() => _SidebarGroupState();
}

class _SidebarGroupState extends State<_SidebarGroup> {
  late bool _expanded = _hasActiveChild;
  bool _hovered = false;

  bool get _hasActiveChild =>
      widget.item.children.any((c) => c.route == widget.currentRoute);

  @override
  void didUpdateWidget(covariant _SidebarGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasActiveChild) _expanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: _hovered ? AppColors.cardYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 19,
                      color: _hovered ? AppColors.textDark : AppColors.textGrey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _hovered
                              ? AppColors.textDark
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_expanded)
          for (final child in item.children)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _SidebarItem(
                icon: child.icon,
                label: child.label,
                isActive: widget.currentRoute == child.route,
                onTap: () => widget.onNavigate(child),
              ),
            ),
      ],
    );
  }
}
