import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/notifications/notification_service.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/core/utils/shared_preferences/shared_preferences_helper.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/trips/trips_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMainScreen extends StatelessWidget {
  const ProfileMainScreen({Key? key}) : super(key: key);

  String get _name {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim();
    }
    if (BasicModel.name.trim().isNotEmpty) return BasicModel.name.trim();
    return 'Travel365 Demo';
  }

  String get _email {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email?.isNotEmpty == true) return email!;
    if (BasicModel.userToken == 'demo-token') return 'demo@travel365.com';
    return 'Signed-in customer';
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You can sign in again at any time to view your bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseAuth.instance.signOut();
    await addStringToSF('userID', '');
    await addStringToSF('name', '');
    await addStringToSF('userToken', '');
    BasicModel.userID = '';
    BasicModel.name = '';
    BasicModel.userToken = '';
    BasicModel.isLogin = false;
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/getStarted', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final horizontal = MediaQuery.of(context).size.width < 360
        ? AppSpacing.screenSmall
        : AppSpacing.screen;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/travel365_logo.svg',
                  width: 100,
                  semanticsLabel: 'Travel365 logo',
                ),
                const Spacer(),
                LuxuryIconButton(
                  icon: Icons.notifications_none_rounded,
                  semanticLabel: 'Notifications',
                  filled: false,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/notifications',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),
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
                        _name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.displayMedium,
                      ),
                      const SizedBox(height: 12),
                      _RoleBadge(userId: firebaseUser?.uid),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _ProfileAvatar(user: firebaseUser, name: _name),
              ],
            ),
            const SizedBox(height: 36),
            Text('Travel account', style: AppTypography.sectionTitle),
            const SizedBox(height: 14),
            _ProfileTile(
              icon: Icons.luggage_outlined,
              title: 'Book a Trip',
              subtitle: 'Plan flights, stays, cars or complete packages',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookTripScreen()),
              ),
            ),
            _ProfileTile(
              icon: Icons.calendar_month_outlined,
              title: 'My Bookings',
              subtitle: 'View your upcoming and past trips',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TripsScreen()),
              ),
            ),
            _ProfileTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Push alerts, email receipts and WhatsApp receipts',
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              trailing: const _NotificationSwitch(),
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Manage your preferences',
              onTap: () => Navigator.pushNamed(context, '/setting'),
            ),
            const _ProfileTile(
              icon: Icons.support_agent_rounded,
              title: 'Help & Support',
              subtitle: 'Contact Travel365 for assistance',
            ),
            const SizedBox(height: 14),
            _ProfileTile(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              subtitle: _email,
              destructive: true,
              onTap: () => _signOut(context),
            ),
            const SizedBox(height: 24),
            Text(
              'Travel365 App - Botswana',
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user, required this.name});
  final User? user;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'T'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();
    return CircleAvatar(
      radius: 38,
      backgroundColor: AppColors.accentSoft,
      backgroundImage: user?.photoURL?.isNotEmpty == true
          ? NetworkImage(user!.photoURL!)
          : null,
      child: user?.photoURL?.isNotEmpty == true
          ? null
          : Text(
              initials,
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const _Badge(label: 'Gold Member');
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        final role = snapshot.data?.data()?['role']?.toString() ?? 'customer';
        return _Badge(
          label: role == 'staff'
              ? 'Travel365 Staff'
              : role == 'owner'
                  ? 'Travel365 Owner'
                  : 'Gold Member',
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_border_rounded,
              size: 15, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final iconColor = destructive ? AppColors.error : AppColors.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LuxuryCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: destructive
                    ? AppColors.error.withAlpha(20)
                    : AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.label.copyWith(
                      color:
                          destructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: destructive ? AppColors.error : AppColors.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatefulWidget {
  const _NotificationSwitch();

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  bool enabled = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await NotificationService.instance.currentDeviceEnabled();
    if (!mounted) return;
    setState(() {
      enabled = value;
      loading = false;
    });
  }

  Future<void> _change(bool value) async {
    setState(() => loading = true);
    final next =
        await NotificationService.instance.setCurrentDeviceEnabled(value);
    if (!mounted) return;
    setState(() {
      enabled = next;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      );
    }
    return Switch.adaptive(
      value: enabled,
      activeThumbColor: AppColors.accent,
      onChanged: _change,
    );
  }
}
