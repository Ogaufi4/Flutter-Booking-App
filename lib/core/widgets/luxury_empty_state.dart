import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:flutter/material.dart';

class LuxuryEmptyState extends StatelessWidget {
  const LuxuryEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(icon, size: 54, color: AppColors.accent),
            ),
            const SizedBox(height: 24),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              LuxuryButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
