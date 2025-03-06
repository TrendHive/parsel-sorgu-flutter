import 'package:domain_ui/values/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ParcelInfoLocalKeys {
  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const Iterable<Locale> supportedLocales = [
    Locale(languageCodeEN), // English
    Locale(languageCodeTR), // Turkish
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const String title = "ParcelInfo";
  static const String languageCodeTR = "tr";
  static const String languageCodeEN = "en";
}
