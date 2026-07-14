import 'package:booking_app/core/utils/extensions/theme_extensions.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

final ThemeData ownThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFE46225),
    secondary: Color(0xFF262261),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFB42318),
    onPrimary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF262833),
  ),
  scaffoldBackgroundColor: OwnTheme.colorPalette['bg'],
  primarySwatch: OwnTheme.primaryColor,
  fontFamily: 'fontEn',
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF262261),
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: OwnTheme.colorPalette['surface'],
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFE7E9EF)),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 8,
    backgroundColor: Colors.white,
    selectedItemColor: OwnTheme.colorPalette['primary'],
    unselectedItemColor: OwnTheme.colorPalette['gray'],
    selectedLabelStyle:
        OwnTheme.smallBoldTextStyle(lang: lang).colorChange(color: 'primary'),
    unselectedLabelStyle:
        OwnTheme.smallTextStyle(lang: lang).colorChange(color: 'gray'),
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: OwnTheme.colorPalette['bgGray'],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE1E4EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE1E4EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF262261), width: 1.4),
    ),
  ),
  dividerColor: const Color(0xFFE7E9EF),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    modalBackgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
);

class OwnTheme {
  //  ------------------------------- colorPalette ----------------------------

  static const Map<String, Color> colorPalette = <String, Color>{
    'white': Color(0xFFFFFFFF),
    'black': Color(0xFF262833),
    'navy': Color(0xFF262261),
    'disable': Color(0xFFD7DAE0),
    'gray': Color(0xFF767A86),
    'bgGray': Color(0xFFF6F7F9),
    'surface': Color(0xFFFFFFFF),
    'surfaceAlt': Color(0xFFFAFAFB),
    'border': Color(0xFFE1E4EA),
    'link': Color(0xFF262261),
    'primary': Color(0xFFE46225),
    'secondary': Color(0xFF262261),
    'danger': Color(0xFFB42318),
    'bg': Color(0xFFFFFFFF),
    'drawer': Color(0xFFF6F7F9),
  };

  static const MaterialColor primaryColor = MaterialColor(
    0xFFE46225,
    <int, Color>{
      50: Color(0xFFFFF5EF),
      100: Color(0xFFFDE5D6),
      200: Color(0xFFF9C9AB),
      300: Color(0xFFF1A477),
      400: Color(0xFFE58148),
      500: Color(0xFFE46225),
      600: Color(0xFFBD5620),
      700: Color(0xFF98431D),
      800: Color(0xFF7A391D),
      900: Color(0xFF63321B),
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
