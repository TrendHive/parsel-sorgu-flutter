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

    final List<List<LatLng>> strips = GeoRules.splitEqual(
      field,
      4,
      bearingDegrees: GeoRules.suggestedCutBearing(field),
    );

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

  test('an equal split cuts along the direction the member chose', () {
    const List<LatLng> square = <LatLng>[
      LatLng(40, 41),
      LatLng(40, 41.001),
      LatLng(40.001, 41.001),
      LatLng(40.001, 41),
    ];
    final List<List<LatLng>> northSouth = GeoRules.splitEqual(
      square,
      2,
      bearingDegrees: 0,
    );
    final List<List<LatLng>> eastWest = GeoRules.splitEqual(
      square,
      2,
      bearingDegrees: 90,
    );
    double midLongitude(List<LatLng> piece) =>
        piece.map((LatLng p) => p.longitude).reduce((a, b) => a + b) /
        piece.length;
    double midLatitude(List<LatLng> piece) =>
        piece.map((LatLng p) => p.latitude).reduce((a, b) => a + b) /
        piece.length;
    expect(midLongitude(northSouth.first), lessThan(41.0005));
    expect(midLongitude(northSouth.last), greaterThan(41.0005));
    expect(midLatitude(eastWest.first), greaterThan(40.0005));
    expect(midLatitude(eastWest.last), lessThan(40.0005));
  });

  test('the suggested cut runs across a long field', () {
    const List<LatLng> longEastWest = <LatLng>[
      LatLng(40, 41),
      LatLng(40, 41.004),
      LatLng(40.0005, 41.004),
      LatLng(40.0005, 41),
    ];
    expect(GeoRules.suggestedCutBearing(longEastWest), closeTo(0, 1));
  });

  test('pieces split among heirs merge back into the whole field', () {
    const List<LatLng> field = <LatLng>[
      LatLng(40, 41),
      LatLng(40.00002, 41.0004),
      LatLng(40.00015, 41.00043),
      LatLng(40.0001, 41.00002),
    ];
    final List<List<LatLng>> strips = GeoRules.splitEqual(
      field,
      4,
      bearingDegrees: 30,
    );
    final List<LatLng>? whole = GeoRules.merge(<List<LatLng>>[
      strips[2],
      strips[0],
      strips[3],
      strips[1],
    ]);
    expect(whole, isNotNull);
    expect(
      GeoRules.areaSquareMeters(whole!),
      closeTo(GeoRules.areaSquareMeters(field), 0.01),
    );
    expect(whole, hasLength(field.length));
  });

  test('pieces that do not touch cannot be merged', () {
    const List<LatLng> far = <LatLng>[
      LatLng(41, 41),
      LatLng(41, 41.001),
      LatLng(41.001, 41.001),
    ];
    expect(GeoRules.merge(<List<LatLng>>[testSquare, far]), isNull);
  });
}
