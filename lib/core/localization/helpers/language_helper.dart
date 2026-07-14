import 'package:booking_app/core/localization/cubit/locale_cubit.dart';
import 'package:booking_app/core/utils/shared_preferences/shared_preferences_helper.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:flutter/foundation.dart';

class LanguageHelper {
  static const String defaultLanguage = 'en';

  Future<void> setLang(String languageCode) async {
    debugPrint('Set language code= $defaultLanguage');
    addStringToSF('lang', defaultLanguage);
    LocaleCubit().changeLanguage(defaultLanguage);
    lang = defaultLanguage;
  }

  Future<String> getLang() async {
    lang = defaultLanguage;
    await addStringToSF('lang', defaultLanguage);
    return defaultLanguage;
  }
}