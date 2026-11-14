import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

void main() {
  final AuditStampValueObject stamp = AuditStampValueObject(
    memberId: 'm',
    memberName: 'M',
    at: DateTime(2026),
  );
  const List<String> siblings = <String>['p1', 'p2', 'p3', 'p4'];

  DrawnParcelEntity drawing(String id, List<OwnershipValueObject> owners) =>
      DrawnParcelEntity(
        id: id,
        name: id,
        outline: const GeoPolygonValueObject(<LatLng>[
          LatLng(40, 41),
          LatLng(40, 41.0001),
          LatLng(40.0001, 41.0001),
          LatLng(40.0001, 41),
        ]),
        officialParcelId: null,
        owners: owners,
        note: '',
        created: stamp,
        updated: stamp,
      );

  final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
    officials: const <OfficialParcelEntity>[],
    persons: <PersonEntity>[
      for (final String id in siblings)
        PersonEntity(
          id: id,
          name: id,
          note: '',
          created: stamp,
          updated: stamp,
        ),
    ],
    groups: <PersonGroupEntity>[
      PersonGroupEntity(
        id: 'family',
        name: 'Family',
        memberIds: siblings,
        note: '',
        created: stamp,
        updated: stamp,
      ),
    ],
    drawings: <DrawnParcelEntity>[
      drawing('shared', <OwnershipValueObject>[
        const OwnershipValueObject(
          kind: HolderKindEnum.group,
          holderId: 'family',
          share: ShareValueObject.whole,
        ),
      ]),
      drawing('own', <OwnershipValueObject>[
        OwnershipValueObject(
          kind: HolderKindEnum.person,
          holderId: 'p1',
          share: ShareValueObject(1, 2),
        ),
      ]),
    ],
  );

  test(
    "a sibling holds a quarter of the family's parcel plus their own share",
    () {
      final HoldingsReadModel holdings = snapshot.holdingsOfPerson('p1');
      expect(holdings.parcelCount, 2);
      final double area = holdings.lines.first.area;
      expect(holdings.ownedArea, closeTo(area / 4 + area / 2, 1e-6));
      expect(
        holdings.lines.map((line) => line.viaGroup?.id),
        containsAll(<String?>['family', null]),
      );
    },
  );

  test('the group itself holds its parcel whole', () {
    final HoldingsReadModel holdings = snapshot.holdingsOfGroup('family');
    expect(holdings.parcelCount, 1);
    expect(holdings.lines.single.share.isWhole, isTrue);
  });

  test('a sibling without a direct share still sees the group parcel', () {
    expect(snapshot.holdingsOfPerson('p4').parcelCount, 1);
  });
}
