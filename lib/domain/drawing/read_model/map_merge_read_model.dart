import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

/// Neighbouring real boundaries being merged back into one.
///
/// [drawings] are the pieces chosen so far, the one it started from first;
/// [toggle] adds a tapped piece or takes it off again (never the first).
/// [outline] is their joined shape, or null while fewer than two are chosen
/// or when they do not all share sides; [canConfirm] says there is one to
/// store and [area] is its area.
///
/// [ownerIds] is everyone who owns any piece — the merged parcel goes to
/// their common ancestor by default. [sameOwners] is whether every piece
/// has exactly the same owners, so they can simply be kept. [name] is the
/// first piece's name without a split's " – 2" or " – heir".
final class MapMergeReadModel extends BaseReadModel {
  MapMergeReadModel._(this.drawings)
    : outline = drawings.length < CoreConstants.two
          ? null
          : GeoRules.merge(<List<LatLng>>[
              for (final DrawnParcelEntity d in drawings) d.outline.corners,
            ]);

  MapMergeReadModel.start(DrawnParcelEntity drawing)
    : this._(<DrawnParcelEntity>[drawing]);

  final List<DrawnParcelEntity> drawings;

  final List<LatLng>? outline;

  DrawnParcelEntity get first => drawings.first;

  MapMergeReadModel toggle(DrawnParcelEntity drawing) {
    if (drawing.id == first.id) return this;
    final bool chosen = drawings.any(
      (DrawnParcelEntity d) => d.id == drawing.id,
    );
    return MapMergeReadModel._(<DrawnParcelEntity>[
      ...drawings.where((DrawnParcelEntity d) => d.id != drawing.id),
      if (!chosen) drawing,
    ]);
  }

  bool contains(String drawingId) =>
      drawings.any((DrawnParcelEntity d) => d.id == drawingId);

  bool get canConfirm => outline != null;

  double get area => outline == null
      ? CoreConstants.zeroDouble
      : GeoRules.areaSquareMeters(outline!);

  Set<String> get ownerIds => <String>{
    for (final DrawnParcelEntity d in drawings)
      for (final OwnershipValueObject line in d.owners) line.personId,
  };

  bool get sameOwners => drawings.every(
    (DrawnParcelEntity d) =>
        d.owners.length == first.owners.length &&
        d.owners.every(first.owners.contains),
  );

  String get name => first.name.split(MapRules.pieceSeparator).first;

  @override
  List<Object?> get props => <Object?>[
    for (final DrawnParcelEntity d in drawings) d.id,
  ];
}
