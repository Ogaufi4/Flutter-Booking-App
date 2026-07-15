import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LuxuryTextField extends StatelessWidget {
  const LuxuryTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLength,
    this.textInputAction,
    this.inputFormatters,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? minLines;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: obscureText,
          maxLength: maxLength,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: maxLength == null ? null : '',
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
