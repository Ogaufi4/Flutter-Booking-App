import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          18,
          AppSpacing.screen,
          32,
        ),
        children: [
          Text('Preferences', style: AppTypography.displayMedium),
          const SizedBox(height: 10),
          Text(
            'Keep Travel365 simple, calm and tailored to you.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 28),
          const _SettingTile(
            icon: Icons.language_rounded,
            title: 'App language',
            value: 'English',
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            value: 'Booking updates enabled',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(height: 12),
          const _SettingTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy',
            value: 'Your booking information stays protected',
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.caption),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
        ],
      ),
    );
  }
}
