import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/read_model/holding_line_read_model.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// Everything the family has stored, as the map sees it.
///
/// [hitAt] answers a tap from what is stored, without the registry: a drawn
/// boundary first (it is on top), then a stored registry parcel, else
/// nothing. Only visible `layers` can be hit — a hidden layer is not tappable.
///
/// [snapTo] pulls a point onto the nearest stored corner within
/// `toleranceMeters`, or else onto the nearest side of a stored outline, so
/// a drawn boundary that touches the registry's, or a neighbour's drawing,
/// shares the line exactly — no gap and no overlap between them.
/// [overlapping] is the first other drawing an outline would cover part of.
///
/// [generations] is how deep the family tree goes; [holdersAt] says which
/// branches of the family, at one level of the tree, a drawing belongs to,
/// and [branchesAt] lists every branch that holds something at that level,
/// in the order the map's legend shows them. [neighbourhoods] are the
/// neighbourhoods of the stored registry parcels, for a search by number.
///
/// [officialById], [drawingById], [personById] look one record up; [drawingsCorrecting] is every drawing linked to a registry parcel;
/// [allCorners] frames the map on what is stored.
///
/// [holdingsOfPerson] is everything that reaches a person: what is recorded
/// on them, and their part of what is recorded on an ancestor whose shares
/// passed down the family tree. [childrenOf] is a person's children.
final class MapSnapshotReadModel extends BaseReadModel {
  const MapSnapshotReadModel({
    required this.officials,
    required this.drawings,
    required this.persons,
  });

  static const MapSnapshotReadModel empty = MapSnapshotReadModel(
    officials: <OfficialParcelEntity>[],
    drawings: <DrawnParcelEntity>[],
    persons: <PersonEntity>[],
  );

  final List<OfficialParcelEntity> officials;

  final List<DrawnParcelEntity> drawings;

  final List<PersonEntity> persons;

  @override
  List<Object?> get props => <Object?>[
    officials.map((OfficialParcelEntity p) => p.refreshed.at).toList(),
    drawings.map((DrawnParcelEntity d) => d.updated.at).toList(),
    persons.map((PersonEntity p) => p.updated?.at).toList(),
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
    if (nearest != null) return nearest;
    for (final List<LatLng> outline in _outlines) {
      final ({LatLng point, double distanceMeters})? side =
          GeoRules.nearestOnRing(outline, point);
      if (side != null && side.distanceMeters <= best) {
        best = side.distanceMeters;
        nearest = side.point;
      }
    }
    return nearest;
  }

  Iterable<List<LatLng>> get _outlines => <List<LatLng>>[
    for (final OfficialParcelEntity parcel in officials)
      parcel.record.outline.corners,
    for (final DrawnParcelEntity drawing in drawings) drawing.outline.corners,
  ];

  DrawnParcelEntity? overlapping(List<LatLng> outline, {String? exceptId}) {
    for (final DrawnParcelEntity drawing in drawings) {
      if (drawing.id == exceptId) continue;
      if (GeoRules.overlapSquareMeters(outline, drawing.outline.corners) >
          MapRules.overlapToleranceSquareMeters) {
        return drawing;
      }
    }
    return null;
  }

  int get generations => FamilyRules.generations(persons);

  Set<String> holdersAt(DrawnParcelEntity drawing, int level) => <String>{
    for (final OwnershipValueObject line in drawing.owners)
      ...FamilyRules.holdersAt(persons, line.personId, level),
  };

  List<PersonEntity> branchesAt(int level) {
    final Set<String> holding = <String>{
      for (final DrawnParcelEntity drawing in drawings)
        ...holdersAt(drawing, level),
    };
    return persons.where((PersonEntity p) => holding.contains(p.id)).toList();
  }

  List<({int id, String name})> get neighbourhoods {
    final Map<int, String> known = <int, String>{
      for (final OfficialParcelEntity parcel in officials)
        parcel.record.neighborhoodId: parcel.record.neighborhoodName,
    };
    return <({int id, String name})>[
      for (final MapEntry<int, String> entry in known.entries)
        (id: entry.key, name: entry.value),
    ];
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

  List<PersonEntity> childrenOf(String personId) =>
      FamilyRules.childrenOf(persons, personId);

  HoldingsReadModel holdingsOfPerson(String personId) {
    final PersonEntity? person = personById(personId);
    if (person == null) {
      return HoldingsReadModel(const <HoldingLineReadModel>[]);
    }
    final bool passedOn = FamilyRules.passes(persons, person);
    final List<HoldingLineReadModel> lines = <HoldingLineReadModel>[];
    for (final DrawnParcelEntity drawing in drawings) {
      for (final OwnershipValueObject line in drawing.owners) {
        final bool direct = line.personId == personId;
        final ShareValueObject? part = direct
            ? ShareValueObject.whole
            : FamilyRules.inheritedPart(
                persons,
                ancestorId: line.personId,
                heirId: personId,
              );
        if (part == null) continue;
        lines.add(
          HoldingLineReadModel(
            drawing: drawing,
            official: officialById(drawing.officialParcelId),
            share: line.share.times(part),
            via: direct ? null : personById(line.personId),
            passedOn: passedOn,
          ),
        );
      }
    }
    return HoldingsReadModel(lines);
  }

  List<DrawnParcelEntity> drawingsCorrecting(String officialId) => drawings
      .where((DrawnParcelEntity d) => d.officialParcelId == officialId)
      .toList();
}
