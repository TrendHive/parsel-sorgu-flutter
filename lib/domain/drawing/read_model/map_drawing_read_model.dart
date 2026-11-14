import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_draft_value_object.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';

/// A drawing session on the map: the [draft] being shaped, the drawing it
/// edits ([editing], null for a new one) and the registry parcel it
/// corrects ([source], null when drawn freehand).
///
/// [crosshair] is the precise-placement mode: a fixed sight in the middle of
/// the map, the map moved under it, and a corner placed with a button — so a
/// finger never covers the spot being marked.
final class MapDrawingReadModel extends BaseReadModel {
  const MapDrawingReadModel({
    required this.draft,
    this.editing,
    this.source,
    this.crosshair = false,
  });

  final DrawingDraftValueObject draft;

  final DrawnParcelEntity? editing;

  final OfficialParcelEntity? source;

  final bool crosshair;

  MapDrawingReadModel withDraft(DrawingDraftValueObject next) =>
      MapDrawingReadModel(
        draft: next,
        editing: editing,
        source: source,
        crosshair: crosshair,
      );

  MapDrawingReadModel withCrosshair({required bool on}) => MapDrawingReadModel(
    draft: draft,
    editing: editing,
    source: source,
    crosshair: on,
  );

  @override
  List<Object?> get props => <Object?>[
    draft,
    editing?.id,
    source?.id,
    crosshair,
  ];
}
