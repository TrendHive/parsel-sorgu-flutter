import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';

void main() {
  const LatLng origin = LatLng(40.5, 41);
  List<LatLng> metres(List<(double, double)> points) =>
      GeoRules.fromLocalPlane(<math.Point<double>>[
        for (final (double x, double y) in points) math.Point<double>(x, y),
      ], origin);

  final List<LatLng> left = metres(<(double, double)>[
    (0, 0),
    (10, 0),
    (10, 20),
    (0, 20),
  ]);
  final List<LatLng> right = metres(<(double, double)>[
    (10, 0),
    (30, 0),
    (30, 20),
    (10, 20),
  ]);

  test('two neighbours wrongly divided are re-cut to the deed shares', () {
    final ({List<LatLng> first, List<LatLng> second})? result =
        GeoRules.redivide(left, right, 0.5);

    expect(result, isNotNull);
    expect(GeoRules.areaSquareMeters(result!.first), closeTo(300, 0.5));
    expect(GeoRules.areaSquareMeters(result.second), closeTo(300, 0.5));
    expect(
      GeoRules.overlapSquareMeters(result.first, result.second),
      lessThan(1),
    );
    expect(
      GeoRules.contains(
        result.first,
        metres(<(double, double)>[(1, 10)]).single,
      ),
      isTrue,
    );
  });

  test(
    'the cut keeps the old dividing line\'s direction and the outer edge',
    () {
      final ({List<LatLng> first, List<LatLng> second})? result =
          GeoRules.redivide(left, right, 0.25);

      expect(GeoRules.areaSquareMeters(result!.first), closeTo(150, 0.5));
      expect(GeoRules.areaSquareMeters(result.second), closeTo(450, 0.5));
      expect(
        GeoRules.areaSquareMeters(result.first) +
            GeoRules.areaSquareMeters(result.second),
        closeTo(600, 0.5),
      );
    },
  );

  test('a neighbour whose corner sits on the other\'s side still joins', () {
    final List<LatLng> short = metres(<(double, double)>[
      (10, 0),
      (30, 0),
      (30, 10),
      (10, 10),
    ]);

    final ({List<LatLng> first, List<LatLng> second})? result =
        GeoRules.redivide(left, short, 0.5);

    expect(result, isNotNull);
    expect(GeoRules.areaSquareMeters(result!.first), closeTo(200, 0.5));
    expect(GeoRules.areaSquareMeters(result.second), closeTo(200, 0.5));
  });

  test('parcels that do not touch cannot be re-divided', () {
    final List<LatLng> far = metres(<(double, double)>[
      (50, 0),
      (60, 0),
      (60, 20),
      (50, 20),
    ]);
    expect(GeoRules.redivide(left, far, 0.5), isNull);
  });
}
