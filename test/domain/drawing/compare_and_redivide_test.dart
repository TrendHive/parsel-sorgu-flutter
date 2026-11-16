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

  MapSnapshotReadModel withDeeds(
    List<OfficialParcelEntity> deeds,
    List<DrawnParcelEntity> real,
  ) => MapSnapshotReadModel(
    officials: deeds,
    drawings: real,
    persons: testFamily,
  );

  test('two neighbours are re-divided so each matches its deed share', () {
    final OfficialParcelEntity deedA = testOfficial(
      '1',
      corners: metres(<(double, double)>[(0, 0), (15, 0), (15, 20), (0, 20)]),
    );
    final OfficialParcelEntity deedB = testOfficial(
      '2',
      corners: metres(<(double, double)>[(15, 0), (30, 0), (30, 20), (15, 20)]),
    );
    final DrawnParcelEntity a = testDrawing(
      'a',
      const <OwnershipValueObject>[],
      corners: leftGround,
      officialParcelId: deedA.id,
    );
    final DrawnParcelEntity b = testDrawing(
      'b',
      const <OwnershipValueObject>[],
      corners: rightGround,
      officialParcelId: deedB.id,
    );
    final MapRedivideReadModel redivide = MapRedivideReadModel.between(
      first: a,
      second: b,
      snapshot: withDeeds(
        <OfficialParcelEntity>[deedA, deedB],
        <DrawnParcelEntity>[a, b],
      ),
    );

    expect(redivide.step, RedivideStepEnum.ready);
    expect(GeoRules.areaSquareMeters(redivide.pieces!.first), closeTo(300, 1));
    expect(GeoRules.areaSquareMeters(redivide.pieces!.second), closeTo(300, 1));
  });

  test('re-dividing needs two different deeds', () {
    final DrawnParcelEntity unlinked = testDrawing(
      'free',
      const <OwnershipValueObject>[],
      corners: metres(<(double, double)>[
        (100, 0),
        (110, 0),
        (110, 10),
        (100, 10),
      ]),
    );
    expect(
      MapRedivideReadModel.between(
        first: left,
        second: unlinked,
        snapshot: withDeeds(
          <OfficialParcelEntity>[leftDeed],
          <DrawnParcelEntity>[left, unlinked],
        ),
      ).step,
      RedivideStepEnum.noDeed,
    );
    final DrawnParcelEntity sameDeed = testDrawing(
      'same',
      const <OwnershipValueObject>[],
      corners: rightGround,
      officialParcelId: leftDeed.id,
    );
    expect(
      MapRedivideReadModel.between(
        first: left,
        second: sameDeed,
        snapshot: withDeeds(
          <OfficialParcelEntity>[leftDeed],
          <DrawnParcelEntity>[left, sameDeed],
        ),
      ).step,
      RedivideStepEnum.sameDeed,
    );
  });

  test('re-dividing a strip of a deed already split among heirs is refused, '
      'so the neighbour does not lose land', () {
    final DrawnParcelEntity strip1 = testDrawing(
      'strip1',
      const <OwnershipValueObject>[],
      corners: metres(<(double, double)>[(0, 0), (5, 0), (5, 20), (0, 20)]),
      officialParcelId: leftDeed.id,
    );
    final DrawnParcelEntity strip2 = testDrawing(
      'strip2',
      const <OwnershipValueObject>[],
      corners: metres(<(double, double)>[(5, 0), (10, 0), (10, 20), (5, 20)]),
      officialParcelId: leftDeed.id,
    );
    expect(
      MapRedivideReadModel.between(
        first: strip2,
        second: right,
        snapshot: withDeeds(
          <OfficialParcelEntity>[leftDeed, rightDeed],
          <DrawnParcelEntity>[strip1, strip2, right],
        ),
      ).step,
      RedivideStepEnum.splitDeed,
    );
  });

  test('a boundary drawn from scratch with a sliver over the neighbour\'s '
      'registry line is not the neighbour\'s', () {
    final DrawnParcelEntity drawn = testDrawing(
      'drawn',
      const <OwnershipValueObject>[],
      corners: metres(<(double, double)>[(0, 0), (12, 0), (12, 20), (0, 20)]),
    );
    final MapSnapshotReadModel snap = withDeeds(
      <OfficialParcelEntity>[leftDeed, rightDeed],
      <DrawnParcelEntity>[drawn],
    );
    expect(snap.drawingsCorrecting(rightDeed), isEmpty);
    expect(snap.drawingsCorrecting(leftDeed).single.id, 'drawn');
    expect(snap.officialOf(drawn)?.id, leftDeed.id);
  });
}
