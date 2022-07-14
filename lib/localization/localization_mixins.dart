import 'package:flutter/material.dart';
import 'package:pos/localization/pos_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getTranslated(BuildContext context, String key) {
  return PosLocalization.of(context).getTranslatedValues(key);
}

// Language Code:
const String ENGLISH = 'en';
const String FARSI = 'fa';
const String PASHTO = 'ps';

// language code
const String LANGUAGE_CODE = 'languageCode';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANGUAGE_CODE, languageCode);

  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH:
      _temp = Locale(languageCode, 'US');
      break;

    case FARSI:
      _temp = Locale(languageCode, 'IR');
      break;

    case PASHTO:
      _temp = Locale(languageCode, 'AR');
      break;

    default:
      _temp = Locale(ENGLISH, 'US');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? 'ENGLISH';

  return _locale(languageCode);
}
