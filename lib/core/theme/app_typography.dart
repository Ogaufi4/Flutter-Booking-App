import 'package:booking_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const _serifFallback = ['Georgia', 'Times New Roman'];

  static const displayLarge = TextStyle(
    fontFamily: 'serif',
    fontFamilyFallback: _serifFallback,
    fontSize: 38,
    height: 1.08,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const displayMedium = TextStyle(
    fontFamily: 'serif',
    fontFamilyFallback: _serifFallback,
    fontSize: 30,
    height: 1.12,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const headingLarge = TextStyle(
    fontFamily: 'fontEnBold',
    fontSize: 24,
    height: 1.25,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const headingMedium = TextStyle(
    fontFamily: 'fontEnBold',
    fontSize: 20,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontFamily: 'fontEnBold',
    fontSize: 17,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'fontEn',
    fontSize: 16,
    height: 1.55,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'fontEn',
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontFamily: 'fontEnBold',
    fontSize: 13,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontFamily: 'fontEnBold',
    fontSize: 15,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
  );

  static const caption = TextStyle(
    fontFamily: 'fontEn',
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
