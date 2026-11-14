import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/map/validator/min_corners_validator.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';

/// A boundary being drawn: its corners, which one is selected, and the
/// history behind undo and redo.
///
/// Every edit answers a new draft and pushes the old corners onto the undo
/// stack, so [undo] walks back one edit at a time — a dragged corner, an added
/// one, a removed one — and [redo] walks forward until the next edit clears
/// it. Nothing here knows about the screen; the map turns taps and drags into
/// these calls.
///
/// `startFrom` seeds a draft from an existing outline — the registry's, when
/// a member corrects an official parcel by moving only the wrong corners.
/// [add] appends a corner, [insertAfter] puts one on an edge (the "+" handle
/// between two corners), [move] drags one, [removeSelected] deletes the
/// selected one, [select] picks one (or none).
///
/// [outline] is the drawn shape as a polygon, measured like any other;
/// [canSave] is whether it encloses an area yet.
final class DrawingDraftValueObject
    extends BaseValueObject<DrawingDraftFields> {
  const DrawingDraftValueObject(super.value);

  static const DrawingDraftValueObject empty = DrawingDraftValueObject((
    corners: <LatLng>[],
    selected: null,
    undoStack: <List<LatLng>>[],
    redoStack: <List<LatLng>>[],
  ));

  factory DrawingDraftValueObject.startFrom(GeoPolygonValueObject outline) =>
      DrawingDraftValueObject((
        corners: List<LatLng>.unmodifiable(outline.corners),
        selected: null,
        undoStack: const <List<LatLng>>[],
        redoStack: const <List<LatLng>>[],
      ));

  @override
  List<BaseValueValidator<DrawingDraftFields>> get validators =>
      const <BaseValueValidator<DrawingDraftFields>>[];

  List<LatLng> get corners => value.corners;

  int? get selected => value.selected;

  bool get canUndo => value.undoStack.isNotEmpty;

  bool get canRedo => value.redoStack.isNotEmpty;

  GeoPolygonValueObject get outline => GeoPolygonValueObject(corners);

  bool get canSave => const MinCornersValidator().validate(corners).isRight;

  DrawingDraftValueObject add(LatLng corner) =>
      _edit(<LatLng>[...corners, corner], selected: corners.length);

  DrawingDraftValueObject insertAfter(int index, LatLng corner) =>
      _edit(<LatLng>[
        ...corners.sublist(CoreConstants.zero, index + 1),
        corner,
        ...corners.sublist(index + 1),
      ], selected: index + 1);

  DrawingDraftValueObject move(int index, LatLng corner) => _edit(<LatLng>[
    for (int i = CoreConstants.zero; i < corners.length; i++)
      i == index ? corner : corners[i],
  ], selected: index);

  DrawingDraftValueObject removeSelected() {
    final int? index = selected;
    if (index == null) return this;
    return _edit(<LatLng>[
      for (int i = CoreConstants.zero; i < corners.length; i++)
        if (i != index) corners[i],
    ], selected: null);
  }

  DrawingDraftValueObject select(int? index) => DrawingDraftValueObject((
    corners: corners,
    selected: index,
    undoStack: value.undoStack,
    redoStack: value.redoStack,
  ));

  DrawingDraftValueObject undo() {
    if (!canUndo) return this;
    return DrawingDraftValueObject((
      corners: value.undoStack.last,
      selected: null,
      undoStack: value.undoStack.sublist(
        CoreConstants.zero,
        value.undoStack.length - 1,
      ),
      redoStack: <List<LatLng>>[...value.redoStack, corners],
    ));
  }

  DrawingDraftValueObject redo() {
    if (!canRedo) return this;
    return DrawingDraftValueObject((
      corners: value.redoStack.last,
      selected: null,
      undoStack: <List<LatLng>>[...value.undoStack, corners],
      redoStack: value.redoStack.sublist(
        CoreConstants.zero,
        value.redoStack.length - 1,
      ),
    ));
  }

  DrawingDraftValueObject _edit(List<LatLng> next, {required int? selected}) =>
      DrawingDraftValueObject((
        corners: List<LatLng>.unmodifiable(next),
        selected: selected,
        undoStack: <List<LatLng>>[...value.undoStack, corners],
        redoStack: const <List<LatLng>>[],
      ));
}

/// The fields of a [DrawingDraftValueObject], named.
typedef DrawingDraftFields = ({
  List<LatLng> corners,
  int? selected,
  List<List<LatLng>> undoStack,
  List<List<LatLng>> redoStack,
});
