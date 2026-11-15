import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

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
}
