import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/features/owner/pages/owner_bookings_screen.dart';
import 'package:booking_app/features/owner/pages/owner_dashboard_screen.dart';
import 'package:booking_app/features/owner/pages/owner_notification_logs_screen.dart';
import 'package:booking_app/features/owner/pages/owner_support_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({Key? key}) : super(key: key);

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int index = 0;
  final pages = const [
    OwnerDashboardScreen(),
    OwnerBookingsScreen(),
    _OwnerProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              _OwnerNavItem(
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard_rounded,
                label: 'Dashboard',
                selected: index == 0,
                onTap: () => setState(() => index = 0),
              ),
              _OwnerNavItem(
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                label: 'Bookings',
                selected: index == 1,
                onTap: () => setState(() => index = 1),
              ),
              _OwnerNavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                selected: index == 2,
                onTap: () => setState(() => index = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerNavItem extends StatelessWidget {
  const _OwnerNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: selected ? AppColors.accent : AppColors.textMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerProfile extends StatelessWidget {
  const _OwnerProfile();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Travel365 Owner';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Owner Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          18,
          AppSpacing.screen,
          32,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good afternoon,', style: AppTypography.caption),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(user?.email ?? '', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.accentSoft,
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.accent,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Operations', style: AppTypography.sectionTitle),
          const SizedBox(height: 12),
          LuxuryCard(
            padding: const EdgeInsets.all(14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OwnerSupportSettingsScreen(),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.support_agent_outlined,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact settings', style: AppTypography.label),
                      const SizedBox(height: 4),
                      Text(
                        'Customer support and owner alert destinations',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LuxuryCard(
            padding: const EdgeInsets.all(14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OwnerNotificationLogsScreen(),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery logs', style: AppTypography.label),
                      const SizedBox(height: 4),
                      Text(
                        'Review email, WhatsApp and push attempts',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LuxuryButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            variant: LuxuryButtonVariant.secondary,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/getStarted',
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
