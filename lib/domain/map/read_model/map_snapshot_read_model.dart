import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_line_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_table_read_model.dart';
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
/// branches of the family, at one level of the tree, a drawing belongs to —
/// or, with no level, simply the people recorded as its owners — and
/// [branchesAt] lists everyone who holds something that way, in the order
/// the map's legend shows them. [officialHoldersAt] is the same for a
/// registry parcel: whoever holds any of its real boundaries, so the
/// registry layer can be coloured by owner on its own. [neighbourhoods] are the
/// neighbourhoods of the stored registry parcels, for a search by number.
///
/// [officialById], [drawingById], [personById] look one record up;
/// [allCorners] frames the map on what is stored.
///
/// [drawingsCorrecting] is every real boundary of a registry parcel: the
/// drawings linked to it, and the ones drawn without a link that lie mostly
/// on its ground (more than [MapRules.coverShare] of their area) — a
/// boundary drawn from scratch is still that parcel's, but a sliver over a
/// neighbour's registry line does not make it the neighbour's. Which parcel
/// each drawing belongs to is worked out once per snapshot.
///
/// [officialOf] is the registry parcel a drawing belongs to: the linked one,
/// or else the one holding most of it, by the same rule.
///
/// [compare] lays the given drawings and registry parcels side by side: a
/// registry parcel stands for its real boundaries, or for itself when
/// nobody drew it; each drawing appears once.
///
/// [holdingsOfPerson] is everything that reaches a person: what is recorded
/// on them, and their part of what is recorded on an ancestor whose shares
/// passed down the family tree. [childrenOf] is a person's children.
final class MapSnapshotReadModel extends BaseReadModel {
  MapSnapshotReadModel({
    required this.officials,
    required this.drawings,
    required this.persons,
  });

  static final MapSnapshotReadModel empty = MapSnapshotReadModel(
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

  Set<String> holdersAt(DrawnParcelEntity drawing, int? level) => <String>{
    for (final OwnershipValueObject line in drawing.owners)
      if (level == null)
        line.personId
      else
        ...FamilyRules.holdersAt(persons, line.personId, level),
  };

  Set<String> officialHoldersAt(OfficialParcelEntity parcel, int? level) =>
      <String>{
        for (final DrawnParcelEntity drawing in drawingsCorrecting(parcel))
          ...holdersAt(drawing, level),
      };

  List<PersonEntity> branchesAt(int? level) {
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

  List<DrawnParcelEntity> drawingsCorrecting(OfficialParcelEntity parcel) =>
      _drawingsOfOfficial[parcel.id] ?? const <DrawnParcelEntity>[];

  late final Map<String, OfficialParcelEntity> _officialOfDrawing =
      <String, OfficialParcelEntity>{
        for (final DrawnParcelEntity drawing in drawings)
          if (_match(drawing) case final OfficialParcelEntity official)
            drawing.id: official,
      };

  late final Map<String, List<DrawnParcelEntity>> _drawingsOfOfficial =
      <String, List<DrawnParcelEntity>>{
        for (final OfficialParcelEntity official in officials)
          official.id: <DrawnParcelEntity>[
            for (final DrawnParcelEntity drawing in drawings)
              if (_officialOfDrawing[drawing.id]?.id == official.id) drawing,
          ],
      };

  OfficialParcelEntity? _match(DrawnParcelEntity drawing) {
    if (drawing.officialParcelId != null) {
      return officialById(drawing.officialParcelId);
    }
    OfficialParcelEntity? best;
    double most = drawing.outline.areaSquareMeters * MapRules.coverShare;
    for (final OfficialParcelEntity official in officials) {
      final double shared = GeoRules.overlapSquareMeters(
        drawing.outline.corners,
        official.record.outline.corners,
      );
      if (shared > most) {
        most = shared;
        best = official;
      }
    }
    return best;
  }

  OfficialParcelEntity? officialOf(DrawnParcelEntity drawing) =>
      _officialOfDrawing[drawing.id];

  CompareTableReadModel compare(List<String> ids) {
    final List<CompareLineReadModel> lines = <CompareLineReadModel>[];
    final Set<String> seen = <String>{};
    void addDrawing(DrawnParcelEntity drawing) {
      if (!seen.add(drawing.id)) return;
      final OfficialParcelEntity? official = officialOf(drawing);
      lines.add(
        CompareLineReadModel(
          drawing: drawing,
          official: official,
          realArea: drawing.outline.areaSquareMeters,
          registryArea: official == null
              ? null
              : _registryPart(official, drawing),
        ),
      );
    }

    for (final String id in ids) {
      final DrawnParcelEntity? drawing = drawingById(id);
      if (drawing != null) {
        addDrawing(drawing);
        continue;
      }
      final OfficialParcelEntity? official = officialById(id);
      if (official == null) continue;
      final List<DrawnParcelEntity> real = drawingsCorrecting(official);
      if (real.isEmpty && seen.add(official.id)) {
        lines.add(
          CompareLineReadModel(
            drawing: null,
            official: official,
            realArea: null,
            registryArea: _registryArea(official),
          ),
        );
      }
      real.forEach(addDrawing);
    }
    return CompareTableReadModel.of(lines, persons);
  }

  double _registryArea(OfficialParcelEntity official) =>
      official.record.registryAreaSquareMeters ??
      official.record.outline.areaSquareMeters;

  double _registryPart(
    OfficialParcelEntity official,
    DrawnParcelEntity drawing,
  ) {
    final double drawn = drawingsCorrecting(official).fold(
      CoreConstants.zeroDouble,
      (double sum, DrawnParcelEntity d) => sum + d.outline.areaSquareMeters,
    );
    return drawn == CoreConstants.zeroDouble
        ? _registryArea(official)
        : _registryArea(official) * drawing.outline.areaSquareMeters / drawn;
  }
}
