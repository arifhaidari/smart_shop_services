import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PosLocalization {
  final Locale locale;

  PosLocalization(this.locale);

  static PosLocalization of(BuildContext context) {
    return Localizations.of<PosLocalization>(context, PosLocalization);
  }

  Map<String, String> _localizedValues;

  Future load() async {
    String jsonStringValues = await rootBundle.loadString("lang/${locale.languageCode}.json");

    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslatedValues(String key) {
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<PosLocalization> delegate = _PosLocalizationDelegate();
}

class _PosLocalizationDelegate extends LocalizationsDelegate<PosLocalization> {
  const _PosLocalizationDelegate();
  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa', 'ps'].contains(locale.languageCode);
  }

  @override
  Future<PosLocalization> load(Locale locale) async {
    PosLocalization localization = new PosLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_PosLocalizationDelegate old) => false;
}
