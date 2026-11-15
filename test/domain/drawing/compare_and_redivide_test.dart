import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/enum/redivide_step_enum.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_owner_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_table_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_redivide_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../../support/fakes.dart';

void main() {
  const LatLng origin = LatLng(40.5, 41);
  List<LatLng> metres(List<(double, double)> points) =>
      GeoRules.fromLocalPlane(<math.Point<double>>[
        for (final (double x, double y) in points) math.Point<double>(x, y),
      ], origin);

  final List<LatLng> leftGround = metres(<(double, double)>[
    (0, 0),
    (10, 0),
    (10, 20),
    (0, 20),
  ]);
  final List<LatLng> rightGround = metres(<(double, double)>[
    (10, 0),
    (30, 0),
    (30, 20),
    (10, 20),
  ]);
  final OfficialParcelEntity leftDeed = testOfficial('1', corners: leftGround);
  final OfficialParcelEntity rightDeed = testOfficial(
    '2',
    corners: rightGround,
  );
  final DrawnParcelEntity left = testDrawing(
    'left',
    <OwnershipValueObject>[
      const OwnershipValueObject(personId: 'a', share: ShareValueObject.whole),
    ],
    corners: leftGround,
    officialParcelId: leftDeed.id,
  );
  final DrawnParcelEntity right = testDrawing(
    'right',
    <OwnershipValueObject>[
      OwnershipValueObject(
        personId: 'b',
        share: ShareValueObject.tryParse('1/4')!,
      ),
    ],
    corners: rightGround,
    officialParcelId: rightDeed.id,
  );
  final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
    officials: <OfficialParcelEntity>[leftDeed, rightDeed],
    drawings: <DrawnParcelEntity>[left, right],
    persons: testFamily,
  );

  test('the comparison totals each owner\'s share, and the unowned rest', () {
    final CompareTableReadModel table = snapshot.compare(<String>[
      leftDeed.id,
      right.id,
    ]);

    expect(table.lines.map((l) => l.drawing?.id), <String>['left', 'right']);
    expect(table.realTotal, closeTo(600, 0.5));
    final List<CompareOwnerReadModel> owners = table.owners;
    expect(owners.map((CompareOwnerReadModel o) => o.person?.id), <String?>[
      'a',
      'b',
      null,
    ]);
    expect(owners.first.realArea, closeTo(200, 0.5));
    expect(owners[1].realArea, closeTo(100, 0.5));
    expect(owners.last.realArea, closeTo(300, 0.5));
    expect(owners.first.registryArea, closeTo(200, 0.5));
  });

  test('a registry parcel nobody drew is compared by its deed alone', () {
    final OfficialParcelEntity bare = testOfficial(
      '9',
      corners: metres(<(double, double)>[
        (100, 100),
        (110, 100),
        (110, 110),
        (100, 110),
      ]),
    );
    final CompareTableReadModel table = MapSnapshotReadModel(
      officials: <OfficialParcelEntity>[bare],
      drawings: const <DrawnParcelEntity>[],
      persons: testFamily,
    ).compare(<String>[bare.id]);

    expect(table.lines.single.realArea, isNull);
    expect(table.lines.single.registryArea, closeTo(100, 0.5));
    expect(table.owners.single.person, isNull);
  });

  test('two neighbours are re-divided so each matches its deed share', () {
    final MapRedivideReadModel redivide = MapRedivideReadModel.between(
      first: left,
      second: right,
      firstOfficial: testOfficial(
        '1',
        corners: metres(<(double, double)>[(0, 0), (15, 0), (15, 20), (0, 20)]),
      ),
      secondOfficial: testOfficial(
        '2',
        corners: metres(<(double, double)>[
          (15, 0),
          (30, 0),
          (30, 20),
          (15, 20),
        ]),
      ),
    );

    expect(redivide.step, RedivideStepEnum.ready);
    expect(GeoRules.areaSquareMeters(redivide.pieces!.first), closeTo(300, 1));
    expect(GeoRules.areaSquareMeters(redivide.pieces!.second), closeTo(300, 1));
  });

  test('re-dividing needs two different deeds', () {
    expect(
      MapRedivideReadModel.between(
        first: left,
        second: right,
        firstOfficial: leftDeed,
        secondOfficial: null,
      ).step,
      RedivideStepEnum.noDeed,
    );
    expect(
      MapRedivideReadModel.between(
        first: left,
        second: right,
        firstOfficial: leftDeed,
        secondOfficial: leftDeed,
      ).step,
      RedivideStepEnum.sameDeed,
    );
  });
}
