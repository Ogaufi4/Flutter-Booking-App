import 'package:booking_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LuxuryIconButton extends StatelessWidget {
  const LuxuryIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.filled = true,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                filled ? AppColors.surface.withAlpha(235) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border.withAlpha(217)),
          ),
          child: Icon(icon, size: 21, color: color ?? AppColors.primary),
        ),
      ),
    );
  }
}
