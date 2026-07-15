import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:flutter/material.dart';

class ProfileListTile extends StatelessWidget {
  final String? text;
  final dynamic icon;
  final Color? iconColor;
  final Function? onTap;

  const ProfileListTile({this.text, this.icon, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LuxuryCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: onTap == null ? null : () => onTap!(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: icon is IconData
                  ? Icon(icon, color: resolvedIconColor, size: 22)
                  : Padding(
                      padding: const EdgeInsets.all(11),
                      child: Image.asset(
                        icon.toString(),
                        color: resolvedIconColor,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text ?? '',
                style: AppTypography.label,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
