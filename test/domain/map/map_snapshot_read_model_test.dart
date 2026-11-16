import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../../support/fakes.dart';

void main() {
  const LatLng inside = LatLng(40.00005, 41.00005);
  const LatLng outside = LatLng(40.001, 41.001);
  final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
    officials: const <OfficialParcelEntity>[],
    persons: const <PersonEntity>[],
    drawings: <DrawnParcelEntity>[
      testDrawing('drawn', const <OwnershipValueObject>[]),
    ],
  );

  test('a tap inside a drawn boundary selects it', () {
    final MapHitReadModel hit = snapshot.hitAt(
      inside,
      MapLayerEnum.values.toSet(),
    );
    expect(hit, isA<MapHitDrawn>());
  });

  test('a hidden layer cannot be tapped', () {
    expect(
      snapshot.hitAt(inside, <MapLayerEnum>{MapLayerEnum.official}),
      isA<MapHitNone>(),
    );
  });

  test('a tap on open ground hits nothing and keeps the point', () {
    final MapHitReadModel hit = snapshot.hitAt(
      outside,
      MapLayerEnum.values.toSet(),
    );
    expect(hit, const MapHitNone(outside));
  });

  test('a corner dropped near a stored corner snaps onto it exactly', () {
    const LatLng near = LatLng(40.000001, 41.000001);
    expect(snapshot.snapTo(near, toleranceMeters: 1), testSquare.first);
    expect(snapshot.snapTo(outside, toleranceMeters: 1), isNull);
  });

  test('assign owner on a registry parcel finds the real boundary drawn on it '
      'without a link, instead of making a second copy', () {
    final OfficialParcelEntity parcel = testOfficial('1');
    const List<LatLng> elsewhere = <LatLng>[
      LatLng(40.01, 41.01),
      LatLng(40.01, 41.0101),
      LatLng(40.0101, 41.0101),
      LatLng(40.0101, 41.01),
    ];
    final MapSnapshotReadModel withDrawings = MapSnapshotReadModel(
      officials: <OfficialParcelEntity>[parcel],
      persons: const <PersonEntity>[],
      drawings: <DrawnParcelEntity>[
        testDrawing('unlinked', const <OwnershipValueObject>[]),
        testDrawing(
          'linked',
          const <OwnershipValueObject>[],
          corners: elsewhere,
          officialParcelId: parcel.id,
        ),
        testDrawing(
          'other',
          const <OwnershipValueObject>[],
          corners: elsewhere,
        ),
        testDrawing(
          'linkedElsewhere',
          const <OwnershipValueObject>[],
          officialParcelId: 'another',
        ),
      ],
    );
    expect(
      withDrawings
          .drawingsCorrecting(parcel)
          .map((DrawnParcelEntity d) => d.id),
      <String>['unlinked', 'linked'],
    );
  });

  test('the map colours a drawing by its recorded owners by default', () {
    final MapSnapshotReadModel owned = MapSnapshotReadModel(
      officials: const <OfficialParcelEntity>[],
      persons: testFamily,
      drawings: <DrawnParcelEntity>[
        testDrawing('owned', <OwnershipValueObject>[
          const OwnershipValueObject(
            personId: 'father',
            share: ShareValueObject.whole,
          ),
        ]),
        testDrawing('free', const <OwnershipValueObject>[]),
      ],
    );
    expect(owned.holdersAt(owned.drawings.first, null), <String>{'father'});
    expect(owned.holdersAt(owned.drawings.last, null), isEmpty);
    expect(owned.branchesAt(null).map((PersonEntity p) => p.id), <String>[
      'father',
    ]);
  });
}
