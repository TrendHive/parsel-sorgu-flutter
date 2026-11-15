import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/geo_polygon_mapper.dart';

/// A drawn parcel as a store document, and back.
///
/// [write] stores the outline AND the measurements computed from it
/// (`measures`), so the numbers a member saw when saving are on record and
/// readable by any tool, not only by this app. Owners are stored as lines
/// (`personId`, `numerator`, `denominator`) plus [ownerIds], the flat list
/// Firestore can query when a person is deleted.
class DrawnParcelDocumentMapper {
  const DrawnParcelDocumentMapper();

  static const String name = 'name';
  static const String outline = 'outline';
  static const String officialParcelId = 'officialParcelId';
  static const String owners = 'owners';
  static const String ownerIds = 'ownerIds';
  static const String note = 'note';
  static const String measures = 'measures';
  static const String area = 'areaSquareMeters';
  static const String perimeter = 'perimeterMeters';
  static const String edges = 'edgeLengthsMeters';
  static const String created = 'created';
  static const String updated = 'updated';
  static const String personId = 'personId';
  static const String numerator = 'numerator';
  static const String denominator = 'denominator';

  static const GeoPolygonMapper _outline = GeoPolygonMapper();
  static const AuditStampMapper _stamps = AuditStampMapper();

  Map<String, Object?> write(
    GeoPolygonValueObject shape,
    DrawingDetailsValueObject details,
    MemberEntity actor,
  ) => <String, Object?>{
    name: details.name,
    outline: _outline.write(shape),
    officialParcelId: details.officialParcelId,
    owners: writeOwners(details.owners),
    ownerIds: writeOwnerIds(details.owners),
    note: details.note,
    measures: <String, Object?>{
      area: shape.areaSquareMeters,
      perimeter: shape.perimeterMeters,
      edges: shape.edgeLengthsMeters,
    },
    updated: _stamps.write(actor),
  };

  List<Map<String, Object?>> writeOwners(List<OwnershipValueObject> lines) =>
      <Map<String, Object?>>[
        for (final OwnershipValueObject line in lines)
          <String, Object?>{
            personId: line.personId,
            numerator: line.share.numerator,
            denominator: line.share.denominator,
          },
      ];

  List<String> writeOwnerIds(List<OwnershipValueObject> lines) => <String>[
    for (final OwnershipValueObject line in lines) line.personId,
  ];

  DrawnParcelEntity? read(String id, Map<String, dynamic> data) {
    final Object? raw = data[owners];
    return DrawnParcelEntity(
      id: id,
      name: '${data[name] ?? CoreConstants.empty}',
      outline: _outline.read(data[outline]),
      officialParcelId: data[officialParcelId] as String?,
      owners: <OwnershipValueObject>[
        if (raw is List)
          for (final Object? line in raw) ?_readOwner(line),
      ],
      note: '${data[note] ?? CoreConstants.empty}',
      created: _stamps.read(data[created]),
      updated: _stamps.read(data[updated]),
    );
  }

  OwnershipValueObject? _readOwner(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final Object? n = raw[numerator];
    final Object? d = raw[denominator];
    final Object? id = raw[personId];
    if (n is! int || d is! int || id is! String) return null;
    return OwnershipValueObject(personId: id, share: ShareValueObject(n, d));
  }
}
