import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';

import '../../support/fakes.dart';

void main() {
  final double whole = GeoRules.areaSquareMeters(testSquare);

  test('a point beside a side snaps onto that side', () {
    final ({LatLng point, double distanceMeters})? nearest =
        GeoRules.nearestOnRing(testSquare, const LatLng(39.99999, 41.00005));

    expect(nearest!.point.latitude, closeTo(40, 1e-9));
    expect(nearest.point.longitude, closeTo(41.00005, 1e-9));
    expect(nearest.distanceMeters, closeTo(1.11, 0.05));
  });

  test('neighbours that share a side share no ground', () {
    const List<LatLng> neighbour = <LatLng>[
      LatLng(40, 41.0001),
      LatLng(40, 41.0002),
      LatLng(40.0001, 41.0002),
      LatLng(40.0001, 41.0001),
    ];

    expect(GeoRules.overlapSquareMeters(testSquare, neighbour), 0);
  });

  test('a drawing laid half over another shares half its ground', () {
    const List<LatLng> shifted = <LatLng>[
      LatLng(40, 41.00005),
      LatLng(40, 41.00015),
      LatLng(40.0001, 41.00015),
      LatLng(40.0001, 41.00005),
    ];

    expect(
      GeoRules.overlapSquareMeters(testSquare, shifted),
      closeTo(whole / 2, whole * 0.03),
    );
  });

  test('a line through a drawing cuts it into two pieces that add up', () {
    final List<List<LatLng>> pieces = GeoRules.splitByLine(
      testSquare,
      const LatLng(39.9999, 41.00003),
      const LatLng(40.0002, 41.00003),
    );

    expect(pieces, hasLength(2));
    final List<double> areas = pieces.map(GeoRules.areaSquareMeters).toList();
    expect(areas[0] + areas[1], closeTo(whole, whole * 1e-6));
    expect(
      areas.reduce((double a, double b) => a < b ? a : b),
      closeTo(whole * 0.3, whole * 0.01),
    );
  });

  test('a line that misses the drawing cuts nothing', () {
    expect(
      GeoRules.splitByLine(
        testSquare,
        const LatLng(41, 41),
        const LatLng(41, 42),
      ),
      isEmpty,
    );
  });

  test('an equal split gives every heir the same area', () {
    const List<LatLng> field = <LatLng>[
      LatLng(40, 41),
      LatLng(40.00002, 41.0004),
      LatLng(40.00015, 41.00043),
      LatLng(40.0001, 41.00002),
    ];
    final double total = GeoRules.areaSquareMeters(field);

    final List<List<LatLng>> strips = GeoRules.splitEqual(field, 4);

    expect(strips, hasLength(4));
    for (final List<LatLng> strip in strips) {
      expect(
        GeoRules.areaSquareMeters(strip),
        closeTo(total / 4, total * 1e-4),
      );
    }
    for (int i = 0; i < strips.length; i++) {
      for (int j = i + 1; j < strips.length; j++) {
        expect(
          GeoRules.overlapSquareMeters(strips[i], strips[j]),
          lessThan(total * 1e-3),
        );
      }
    }
  });
}
