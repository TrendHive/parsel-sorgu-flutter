import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';

/// The app's languages. Turkish is the template and the default; English is
/// the translation kept for completeness.
class ParcelInfoLocalKeys {
  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const Iterable<Locale> supportedLocales = <Locale>[
    Locale(languageCodeTR),
    Locale(languageCodeEN),
  ];

  static const Locale defaultLocale = Locale(languageCodeTR);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const String languageCodeTR = "tr";
  static const String languageCodeEN = "en";
}
