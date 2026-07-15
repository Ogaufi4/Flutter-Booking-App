import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class LuxurySectionHeader extends StatelessWidget {
  const LuxurySectionHeader({
    Key? key,
    required this.title,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.sectionTitle)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction ?? () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              textStyle: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
