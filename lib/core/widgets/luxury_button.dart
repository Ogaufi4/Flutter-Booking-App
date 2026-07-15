import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum LuxuryButtonVariant { primary, secondary, text, destructive }

class LuxuryButton extends StatefulWidget {
  const LuxuryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.variant = LuxuryButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final LuxuryButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  State<LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == LuxuryButtonVariant.primary;
    final isDestructive = widget.variant == LuxuryButtonVariant.destructive;
    final isText = widget.variant == LuxuryButtonVariant.text;
    final background = isText
        ? Colors.transparent
        : isPrimary
            ? AppColors.primary
            : Colors.transparent;
    final foreground = isPrimary
        ? Colors.white
        : isDestructive
            ? AppColors.error
            : AppColors.primary;
    final border = isPrimary || isText
        ? Border.all(color: Colors.transparent)
        : Border.all(color: isDestructive ? AppColors.error : AppColors.border);

    return Semantics(
      button: true,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: _enabled
              ? (_) {
                  setState(() => _pressed = false);
                  if (isPrimary) HapticFeedback.lightImpact();
                  widget.onPressed?.call();
                }
              : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _enabled ? 1 : 0.55,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: isText ? 44 : 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: border,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(foreground),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: foreground),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.button
                                  .copyWith(color: foreground),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
