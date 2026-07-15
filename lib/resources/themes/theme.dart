import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

final ThemeData ownThemeData = AppTheme.light;

class OwnTheme {
  //  ------------------------------- colorPalette ----------------------------

  static const Map<String, Color> colorPalette = <String, Color>{
    'white': AppColors.surface,
    'black': AppColors.textPrimary,
    'navy': AppColors.primary,
    'disable': AppColors.textMuted,
    'gray': AppColors.textSecondary,
    'bgGray': AppColors.background,
    'surface': AppColors.surface,
    'surfaceAlt': AppColors.accentSoft,
    'border': AppColors.border,
    'link': AppColors.primary,
    'primary': AppColors.accent,
    'secondary': AppColors.primary,
    'danger': AppColors.error,
    'bg': AppColors.background,
    'drawer': AppColors.background,
  };

  static const MaterialColor primaryColor = MaterialColor(
    0xFFC98224,
    <int, Color>{
      50: AppColors.accentSoft,
      100: Color(0xFFF3DFC4),
      200: Color(0xFFE9C991),
      300: Color(0xFFD9A85C),
      400: Color(0xFFC98224),
      500: AppColors.accent,
      600: Color(0xFFA4681D),
      700: Color(0xFF805016),
      800: Color(0xFF603D12),
      900: Color(0xFF442A0C),
    },
  );

//  ------------------------------- Various Fonts Style -------------------------

  static TextStyle hugeBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 30.sp,
        color: colorPalette['black'],
        fontWeight: FontWeight.w500,
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }

  static TextStyle titleTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 20.sp,
        color: colorPalette['black'],
        fontFamily: lang == "ar" ? "fontAr" : "fontEn");
  }

  static TextStyle titleBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 20.sp,
        color: colorPalette['black'],
        fontWeight: FontWeight.w500,
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }

  static TextStyle avTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 18.sp,
        color: colorPalette['black'],
        fontFamily: lang == "ar" ? "fontAr" : "fontEn");
  }

  static TextStyle avBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: colorPalette['black'],
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }

  static TextStyle prNormalTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 12.sp,
        color: colorPalette['black'],
        height: 1.5,
        fontFamily: lang == "ar" ? "fontAr" : "fontEn");
  }

  static TextStyle prBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 12.sp,
        color: colorPalette['black'],
        fontWeight: FontWeight.w500,
        height: 1.5,
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }

  static TextStyle suitableTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 14.sp,
        color: colorPalette['black'],
        fontFamily: lang == "ar" ? "fontAr" : "fontEn");
  }

  static TextStyle suitableBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 14.sp,
        color: colorPalette['black'],
        fontWeight: FontWeight.w500,
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }

  static TextStyle normalTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 12.sp,
        color: colorPalette['black'],
        fontFamily: lang == "ar" ? "fontAr" : "fontEn");
  }

  static TextStyle normalBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 12.sp,
        color: colorPalette['black'],
        fontWeight: FontWeight.w500,
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }

  static TextStyle smallTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 10.sp,
        color: colorPalette['black'],
        fontFamily: lang == "ar" ? "fontAr" : "fontEn");
  }

  static TextStyle smallBoldTextStyle({required String lang}) {
    return TextStyle(
        fontSize: 10.sp,
        color: colorPalette['black'],
        fontWeight: FontWeight.w500,
        fontFamily: lang == "ar" ? "fontArBold" : "fontEnBold");
  }
}
