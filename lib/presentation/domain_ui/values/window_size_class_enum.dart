/// Material 3's window size classes — the only thing layout branches on.
///
/// A layout decision depends on the space the app has, never on whether the
/// device is a phone, a tablet or a computer: a desktop browser can be
/// narrow and a tablet can be split. [of] classifies a window width in
/// logical pixels: [compact] below 600, [medium] below 840, [expanded] below
/// 1200, [large] below 1600, [extraLarge] from there.
enum WindowSizeClassEnum {
  compact(0),
  medium(600),
  expanded(840),
  large(1200),
  extraLarge(1600);

  const WindowSizeClassEnum(this.minWidth);

  final double minWidth;

  static WindowSizeClassEnum of(double width) =>
      values.lastWhere((WindowSizeClassEnum size) => width >= size.minWidth);

  bool isAtLeast(WindowSizeClassEnum other) => index >= other.index;
}
