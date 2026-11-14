/// The app's own measurements, beside the generic `BaseDimens`.
///
/// [controlHeight] is the smallest height of a button or field.
/// [panelMaxWidth] caps the details panel on a wide screen, where it sits at
/// the side; [panelMaxHeightFactor] is the share of a phone's height it may
/// take at the bottom; [wideLayout] is the width from which the panel moves
/// to the side.
///
/// Map: [cornerHandle] and [edgeHandle] are the touch sizes of a drawing's
/// corner and "+" handles; [outline] and [selectedOutline] stroke widths;
/// [crosshair] the precise-placement sight; [fillAlpha] the polygons'
/// see-through fill.
class ParcelInfoDimens {
  ParcelInfoDimens._();

  static const double controlHeight = 48;
  static const double fieldGap = 12;
  static const double shareFieldWidth = 96;
  static const double progressSize = 20;
  static const double panelMaxWidth = 440;
  static const double toolbarMaxWidth = 760;
  static const double panelMaxHeightFactor = 0.55;
  static const double wideLayout = 900;

  static const double cornerHandle = 30;
  static const double edgeHandle = 24;
  static const double outline = 2;
  static const double selectedOutline = 4;
  static const double drawingOutline = 3;
  static const double crosshair = 44;
  static const double fillAlpha = 0.22;
  static const double dash = 8;
  static const double draggingScale = 1.35;
  static const double restScale = 1;
  static const double edgeLabelWidth = 96;
  static const double edgeLabelHeight = 24;
  static const double parcelLabelWidth = 96;
  static const double parcelLabelHeight = 22;
  static const double parcelLabelMinZoom = 17;
}
