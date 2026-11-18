import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

/// Builders for test data: a stamp, a person in a tree, a square drawing.
final AuditStampValueObject testStamp = AuditStampValueObject(
  memberId: 'm',
  memberName: 'M',
  at: DateTime(2026),
);

PersonEntity testPerson(
  String id, {
  String? parentId,
  String? spouseId,
  bool passesToChildren = false,
}) => PersonEntity(
  id: id,
  name: id,
  parentId: parentId,
  spouseId: spouseId,
  passesToChildren: passesToChildren,
  note: '',
  created: testStamp,
  updated: testStamp,
);

const List<LatLng> testSquare = <LatLng>[
  LatLng(40, 41),
  LatLng(40, 41.0001),
  LatLng(40.0001, 41.0001),
  LatLng(40.0001, 41),
];

DrawnParcelEntity testDrawing(
  String id,
  List<OwnershipValueObject> owners, {
  List<LatLng> corners = testSquare,
  String? officialParcelId,
}) => DrawnParcelEntity(
  id: id,
  name: id,
  outline: GeoPolygonValueObject(corners),
  officialParcelId: officialParcelId,
  owners: owners,
  note: '',
  created: testStamp,
  updated: testStamp,
);

/// A registry parcel, block 101, with the given number and outline.
OfficialParcelEntity testOfficial(
  String parcel, {
  List<LatLng> corners = testSquare,
}) => OfficialParcelEntity(
  record: RegistryRecordValueObject((
    neighborhoodId: 1,
    block: '101',
    parcel: parcel,
    cityName: '',
    districtName: '',
    neighborhoodName: '',
    locality: '',
    quality: '',
    sheet: '',
    landStatus: '',
    status: '',
    registryAreaSquareMeters: null,
    outline: GeoPolygonValueObject(corners),
    attributes: const <String, String>{},
  )),
  created: testStamp,
  refreshed: testStamp,
);

/// A three-generation tree: grandfather → (father, uncle); father → four
/// siblings a, b, c, d. Grandfather's and father's shares have passed on.
final List<PersonEntity> testFamily = <PersonEntity>[
  testPerson('grandfather', passesToChildren: true),
  testPerson('father', parentId: 'grandfather', passesToChildren: true),
  testPerson('uncle', parentId: 'grandfather'),
  for (final String id in <String>['a', 'b', 'c', 'd'])
    testPerson(id, parentId: 'father'),
];
