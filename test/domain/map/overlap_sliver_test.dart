import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';

import '../../support/fakes.dart';

/// A registry parcel about 30 m by 30 m, and its neighbour to the north
/// drawn by hand: the shared side is drawn [into] metres south of the
/// registry's line, so the two lie over each other in a strip that wide.
List<LatLng> _north(double into) {
  const double metersPerDegree = 111132;
  final double south = 40.00027 - into / metersPerDegree;
  return <LatLng>[
    LatLng(south, 41),
    LatLng(south, 41.00035),
    const LatLng(40.0005, 41.00035),
    const LatLng(40.0005, 41),
  ];
}

const List<LatLng> _registry = <LatLng>[
  LatLng(40, 41),
  LatLng(40, 41.00035),
  LatLng(40.00027, 41.00035),
  LatLng(40.00027, 41),
];

MapSnapshotReadModel _with(List<LatLng> neighbour) => MapSnapshotReadModel(
  officials: const <OfficialParcelEntity>[],
  drawings: <DrawnParcelEntity>[
    testDrawing('110/65', const <OwnershipValueObject>[], corners: neighbour),
  ],
  persons: const <PersonEntity>[],
);

void main() {
  test(
    'assigning an owner on a registry parcel is not refused as an overlap '
    'when the neighbour drawn by hand crosses the shared line by a sliver',
    () {
      expect(_with(_north(0.3)).overlapping(_registry), isNull);
    },
  );

  test('a neighbour reaching metres into the parcel is still an overlap', () {
    expect(_with(_north(3)).overlapping(_registry), isNotNull);
  });
}
