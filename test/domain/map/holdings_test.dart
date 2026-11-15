import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/read_model/holding_line_read_model.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../../support/fakes.dart';

void main() {
  final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
    officials: const <OfficialParcelEntity>[],
    persons: testFamily,
    drawings: <DrawnParcelEntity>[
      testDrawing('estate', const <OwnershipValueObject>[
        OwnershipValueObject(personId: 'father', share: ShareValueObject.whole),
      ]),
      testDrawing('own', <OwnershipValueObject>[
        OwnershipValueObject(personId: 'a', share: ShareValueObject(1, 2)),
      ]),
    ],
  );

  test("a sibling holds a quarter of the father's parcel plus their own", () {
    final HoldingsReadModel holdings = snapshot.holdingsOfPerson('a');
    expect(holdings.parcelCount, 2);
    final double area = holdings.lines.first.area;
    expect(holdings.ownedArea, closeTo(area / 4 + area / 2, 1e-6));
    expect(
      holdings.lines.map((HoldingLineReadModel line) => line.via?.id),
      containsAll(<String?>['father', null]),
    );
  });

  test("the father's page still lists what he left, marked as passed on", () {
    final HoldingsReadModel holdings = snapshot.holdingsOfPerson('father');
    expect(holdings.parcelCount, 1);
    expect(holdings.lines.single.share.isWhole, isTrue);
    expect(holdings.lines.single.passedOn, isTrue);
  });

  test('a sibling with nothing of their own still sees the inheritance', () {
    final HoldingsReadModel holdings = snapshot.holdingsOfPerson('d');
    expect(holdings.parcelCount, 1);
    expect(holdings.lines.single.share, ShareValueObject(1, 4));
  });

  test("the uncle gets nothing from his brother's parcel", () {
    expect(snapshot.holdingsOfPerson('uncle').parcelCount, 0);
  });
}
