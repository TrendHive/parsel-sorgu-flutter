import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/read_model/holding_line_read_model.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

/// Everything the family has stored, as the map sees it.
///
/// [hitAt] answers a tap from what is stored, without the registry: a drawn
/// boundary first (it is on top), then a stored registry parcel, else
/// nothing. Only visible `layers` can be hit — a hidden layer is not tappable.
///
/// [snapTo] pulls a point onto the nearest stored corner within
/// `toleranceMeters`, so a drawn boundary that shares a corner with the
/// registry, or with a neighbour's drawing, shares it exactly.
///
/// [officialById], [drawingById], [personById], [groupById] look one record
/// up; [drawingsCorrecting] is every drawing linked to a registry parcel;
/// [allCorners] frames the map on what is stored.
///
/// [holdingsOfPerson] is everything a person holds — directly, and through
/// every group they belong to, a group's share split equally among its
/// members. [holdingsOfGroup] is everything a group holds, at the group's
/// share. [groupsOf] is the groups a person is in.
final class MapSnapshotReadModel extends BaseReadModel {
  const MapSnapshotReadModel({
    required this.officials,
    required this.drawings,
    required this.persons,
    required this.groups,
  });

  static const MapSnapshotReadModel empty = MapSnapshotReadModel(
    officials: <OfficialParcelEntity>[],
    drawings: <DrawnParcelEntity>[],
    persons: <PersonEntity>[],
    groups: <PersonGroupEntity>[],
  );

  final List<OfficialParcelEntity> officials;

  final List<DrawnParcelEntity> drawings;

  final List<PersonEntity> persons;

  final List<PersonGroupEntity> groups;

  @override
  List<Object?> get props => <Object?>[
    officials.map((OfficialParcelEntity p) => p.refreshed.at).toList(),
    drawings.map((DrawnParcelEntity d) => d.updated.at).toList(),
    persons.map((PersonEntity p) => p.updated?.at).toList(),
    groups.map((PersonGroupEntity g) => g.updated?.at).toList(),
  ];

  bool get isEmpty => officials.isEmpty && drawings.isEmpty;

  MapHitReadModel hitAt(LatLng point, Set<MapLayerEnum> layers) {
    if (layers.contains(MapLayerEnum.drawn)) {
      for (final DrawnParcelEntity drawing in drawings.reversed) {
        if (drawing.outline.contains(point)) return MapHitDrawn(drawing);
      }
    }
    final OfficialParcelEntity? official = officialAt(point);
    if (layers.contains(MapLayerEnum.official) && official != null) {
      return MapHitOfficial(official);
    }
    return MapHitNone(point);
  }

  OfficialParcelEntity? officialAt(LatLng point) {
    for (final OfficialParcelEntity parcel in officials) {
      if (parcel.record.outline.contains(point)) return parcel;
    }
    return null;
  }

  LatLng? snapTo(LatLng point, {required double toleranceMeters}) {
    LatLng? nearest;
    double best = toleranceMeters;
    for (final LatLng corner in allCorners) {
      final double distance = GeoRules.distanceMeters(point, corner);
      if (distance <= best) {
        best = distance;
        nearest = corner;
      }
    }
    return nearest;
  }

  List<LatLng> get allCorners => <LatLng>[
    for (final OfficialParcelEntity parcel in officials)
      ...parcel.record.outline.corners,
    for (final DrawnParcelEntity drawing in drawings)
      ...drawing.outline.corners,
  ];

  OfficialParcelEntity? officialById(String? id) {
    for (final OfficialParcelEntity parcel in officials) {
      if (parcel.id == id) return parcel;
    }
    return null;
  }

  DrawnParcelEntity? drawingById(String id) {
    for (final DrawnParcelEntity drawing in drawings) {
      if (drawing.id == id) return drawing;
    }
    return null;
  }

  PersonEntity? personById(String id) {
    for (final PersonEntity person in persons) {
      if (person.id == id) return person;
    }
    return null;
  }

  PersonGroupEntity? groupById(String id) {
    for (final PersonGroupEntity group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  List<PersonGroupEntity> groupsOf(String personId) => groups
      .where((PersonGroupEntity group) => group.hasMember(personId))
      .toList();

  HoldingsReadModel holdingsOfPerson(String personId) {
    final List<HoldingLineReadModel> lines = <HoldingLineReadModel>[];
    for (final DrawnParcelEntity drawing in drawings) {
      for (final OwnershipValueObject line in drawing.owners) {
        final PersonGroupEntity? group = line.kind == HolderKindEnum.group
            ? groupById(line.holderId)
            : null;
        final bool direct = line.holds(HolderKindEnum.person, personId);
        final bool viaGroup = group != null && group.hasMember(personId);
        if (!direct && !viaGroup) continue;
        lines.add(
          HoldingLineReadModel(
            drawing: drawing,
            official: officialById(drawing.officialParcelId),
            share: direct
                ? line.share
                : line.share.dividedBy(group!.memberIds.length),
            viaGroup: direct ? null : group,
          ),
        );
      }
    }
    return HoldingsReadModel(lines);
  }

  HoldingsReadModel holdingsOfGroup(String groupId) =>
      HoldingsReadModel(<HoldingLineReadModel>[
        for (final DrawnParcelEntity drawing in drawings)
          for (final OwnershipValueObject line in drawing.owners)
            if (line.holds(HolderKindEnum.group, groupId))
              HoldingLineReadModel(
                drawing: drawing,
                official: officialById(drawing.officialParcelId),
                share: line.share,
                viaGroup: null,
              ),
      ]);

  List<DrawnParcelEntity> drawingsCorrecting(String officialId) => drawings
      .where((DrawnParcelEntity d) => d.officialParcelId == officialId)
      .toList();
}
