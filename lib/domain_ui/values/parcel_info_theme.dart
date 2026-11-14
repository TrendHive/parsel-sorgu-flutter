import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';

/// The app's light and dark themes, built on the brand colours.
///
/// Controls are sized for ease of use outdoors and for older hands: buttons
/// and fields are at least [ParcelInfoDimens.controlHeight] tall. The font is
/// the platform's own — nothing is downloaded at start, so the app opens the
/// same offline as online.
class ParcelInfoTheme {
  ParcelInfoTheme._();

  static final ThemeData lightTheme = _theme(
    brightness: Brightness.light,
    background: ParcelInfoColor.background01Light,
    surface: ParcelInfoColor.background02Light,
    title: ParcelInfoColor.fontColorTitleLight,
    body: ParcelInfoColor.fontColorDescLight,
  );

  static final ThemeData darkTheme = _theme(
    brightness: Brightness.dark,
    background: ParcelInfoColor.background01Dark,
    surface: ParcelInfoColor.background02Dark,
    title: ParcelInfoColor.fontColorTitleDark,
    body: ParcelInfoColor.fontColorDescDark,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color title,
    required Color body,
  }) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: ParcelInfoColor.brandDefaultLight,
      brightness: brightness,
    ).copyWith(primary: ParcelInfoColor.brandMediumLight, surface: surface);
    const Size minimum = Size(
      ParcelInfoDimens.controlHeight,
      ParcelInfoDimens.controlHeight,
    );
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BaseDimens.radius.medium),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: ThemeData(brightness: brightness).textTheme
          .apply(bodyColor: body, displayColor: title),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: minimum, shape: shape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: minimum, shape: shape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: minimum, shape: shape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BaseDimens.radius.medium),
        ),
      ),
    );
  }
}
