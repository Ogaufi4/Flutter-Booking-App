import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class SettingListTile extends StatelessWidget {
  final String? text;
  final String? value;
  final dynamic icon;
  final Color? iconColor;
  final Widget? widget;
  final Function? onTap;

  const SettingListTile(
      {this.text,
      this.icon,
      this.iconColor,
      this.onTap,
      this.widget,
      this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap != null ? onTap!() : null;
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text ?? '',
                style: AppTypography.bodyLarge,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            widget ??
                Text(
                  value ?? '',
                  style: AppTypography.label,
                ),
            if (icon is IconData)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.textMuted,
                  size: 22,
                ),
              ),
            if (icon is String)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Image.asset(
                  icon.toString(),
                  width: 22,
                  height: 22,
                  color: iconColor ?? AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
