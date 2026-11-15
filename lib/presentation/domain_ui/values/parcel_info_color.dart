import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_color.dart';

class ParcelInfoColor {
  final bool isDarkMode;

  ParcelInfoColor(BuildContext context)
    : isDarkMode = Theme.of(context).brightness == Brightness.dark;

  static const Color background01Light = Color(0xffEDF2F7);
  static const Color background01Dark = Color(0xff1C1C1C);
  late Color background01 = isDarkMode ? background01Dark : background01Light;

  static const Color background02Light = Color(0xffF5F5F5);
  static const Color background02Dark = Color(0xff131313);
  late Color background02 = isDarkMode ? background02Dark : background02Light;

  static const Color successButtonLight = Color(0xff358C42);
  static const Color successButtonDark = Color(0xff358C42);
  late Color successButton = isDarkMode
      ? successButtonDark
      : successButtonLight;

  static const Color dangerButtonLight = Color(0xffAC2B2B);
  static const Color dangerButtonDark = Color(0xffAC2B2B);
  late Color dangerButton = isDarkMode ? dangerButtonDark : dangerButtonLight;

  static const Color primaryButtonLight = Color(0xff3E96CD);
  static const Color primaryButtonDark = Color(0xff3E96CD);
  late Color primaryButton = isDarkMode
      ? primaryButtonDark
      : primaryButtonLight;

  static const Color functionButtonLight = Color(0xff506979);
  static const Color functionButtonDark = Color(0xff506979);
  late Color functionButton = isDarkMode
      ? functionButtonDark
      : functionButtonLight;

  static const Color brandVeryLowLight = Color(0xffFBFAFA);
  static const Color brandVeryLowDark = Color(0xffFBFAFA);
  late Color brandVeryLow = isDarkMode ? brandVeryLowDark : brandVeryLowLight;

  static const Color brandLowLight = Color(0xffFDD095);
  static const Color brandLowDark = Color(0xffFDD095);
  late Color brandLow = isDarkMode ? brandLowDark : brandLowLight;

  static const Color brandDefaultLight = Color(0xffFC8C3C);
  static const Color brandDefaultDark = Color(0xffFC8C3C);
  late Color brandDefault = isDarkMode ? brandDefaultDark : brandDefaultLight;

  static const Color brandMediumLight = Color(0xffEA7738);
  static const Color brandMediumDark = Color(0xffEA7738);
  late Color brandMedium = isDarkMode ? brandMediumDark : brandMediumLight;

  static const Color brandDarkerLight = Color(0xff8F2C07);
  static const Color brandDarkerDark = Color(0xff8F2C07);
  late Color brandDarker = isDarkMode ? brandDarkerDark : brandDarkerLight;

  static const Color fontColorTitleLight = Color(0xff202020);
  static const Color fontColorTitleDark = Color(0xffEEEEEE);
  late Color fontColorTitle = isDarkMode
      ? fontColorTitleDark
      : fontColorTitleLight;

  static const Color fontColorDescLight = Color(0xff404040);
  static const Color fontColorDescDark = Color(0xffC8C8C8);
  late Color fontColorDesc = isDarkMode
      ? fontColorDescDark
      : fontColorDescLight;

  /// The registry's layer: a cool cyan that reads on aerial imagery.
  static const Color officialStroke = Color(0xff29B6F6);

  /// The family's drawn layer: the brand's warm orange, the colour of "ours".
  static const Color drawnStroke = Color(0xffFFA726);

  /// The selected parcel's outline.
  static const Color selectedStroke = Color(0xffFFFFFF);

  /// A drawing in progress, its corner handles and its "+" handles.
  static const Color draftStroke = Color(0xffFFEB3B);
  static const Color handleFill = Color(0xffFFFFFF);
  static const Color handleBorder = Color(0xffE65100);
  static const Color handleSelected = Color(0xffD32F2F);
  static const Color edgeHandleFill = Color(0xccFFFFFF);

  /// Labels drawn over imagery: dark text on a light chip.
  static const Color mapLabelBackground = Color(0xe6FFFFFF);
  static const Color mapLabelText = Color(0xff202020);

  /// A warning line, such as shares that do not add up.
  static const Color warning = Color(0xffB26A00);

  static const Color transparent = Colors.transparent;
  static const Color white = BaseColor.white;
  static const Color black = BaseColor.black;
}
