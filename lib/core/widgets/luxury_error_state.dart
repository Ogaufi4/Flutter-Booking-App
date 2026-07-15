import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:flutter/material.dart';

/// A calm, customer-safe error state mirroring [LuxuryEmptyState].
///
/// It displays only the [title] and [message] it is given, so callers are
/// responsible for passing human-readable copy. It never surfaces Firestore
/// exceptions, rule names, or stack traces itself.
class LuxuryErrorState extends StatelessWidget {
  const LuxuryErrorState({
    Key? key,
    this.icon = Icons.error_outline_rounded,
    this.title = 'Something went wrong',
    required this.message,
    this.retryLabel = 'Try again',
    this.onRetry,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

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
                color: AppColors.error.withAlpha(23),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(icon, size: 54, color: AppColors.error),
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
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              LuxuryButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: LuxuryButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
