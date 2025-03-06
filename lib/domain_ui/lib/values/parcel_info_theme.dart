import 'package:domain_ui/values/parcel_info_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcelInfoTheme {
  ParcelInfoTheme._();

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ParcelInfoColor.background01Light,
    colorScheme: const ColorScheme.light().copyWith(
      primary: ParcelInfoColor.brandDefaultLight,
      surface: ParcelInfoColor.background02Light,
    ),
    textTheme: GoogleFonts.beVietnamProTextTheme().copyWith(
      titleLarge: const TextStyle(color: ParcelInfoColor.fontColorTitleLight),
      titleMedium: const TextStyle(color: ParcelInfoColor.fontColorTitleLight),
      titleSmall: const TextStyle(color: ParcelInfoColor.fontColorTitleLight),
      bodyLarge: const TextStyle(color: ParcelInfoColor.fontColorDescLight),
      bodyMedium: const TextStyle(color: ParcelInfoColor.fontColorDescLight),
      bodySmall: const TextStyle(color: ParcelInfoColor.fontColorDescLight),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ParcelInfoColor.background01Dark,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: ParcelInfoColor.brandDefaultDark,
      surface: ParcelInfoColor.background02Dark,
    ),
    textTheme: GoogleFonts.beVietnamProTextTheme().copyWith(
      titleLarge: const TextStyle(color: ParcelInfoColor.fontColorTitleDark),
      titleMedium: const TextStyle(color: ParcelInfoColor.fontColorTitleDark),
      titleSmall: const TextStyle(color: ParcelInfoColor.fontColorTitleDark),
      bodyLarge: const TextStyle(color: ParcelInfoColor.fontColorDescDark),
      bodyMedium: const TextStyle(color: ParcelInfoColor.fontColorDescDark),
      bodySmall: const TextStyle(color: ParcelInfoColor.fontColorDescDark),
    ),
  );
}
