import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';

void main() {
  List<LatLng> fixtureRing() {
    final Map<String, dynamic> json = jsonDecode(
      File('test/support/fixtures/tkgm_parcel_duzkoy_114_1.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final List<dynamic> ring =
        ((json['geometry'] as Map<String, dynamic>)['coordinates']
                    as List<dynamic>)
                .first
            as List<dynamic>;
    return <LatLng>[
      for (final dynamic pair in ring)
        LatLng(
          ((pair as List<dynamic>)[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        ),
    ];
  }

  test('a 10 m square measures 100 m² and 40 m around', () {
    const LatLng origin = LatLng(40.559, 41.0);
    final double dLat =
        10 / GeoRules.meridianRadius(origin.latitude) * 180 / math.pi;
    final double dLng =
        10 /
        (GeoRules.primeVerticalRadius(origin.latitude) *
            math.cos(origin.latitude * math.pi / 180)) *
        180 /
        math.pi;
    final List<LatLng> square = <LatLng>[
      origin,
      LatLng(origin.latitude, origin.longitude + dLng),
      LatLng(origin.latitude + dLat, origin.longitude + dLng),
      LatLng(origin.latitude + dLat, origin.longitude),
    ];
    expect(GeoRules.areaSquareMeters(square), closeTo(100, 0.001));
    expect(GeoRules.perimeterMeters(square), closeTo(40, 0.001));
  });

  test('the registry sample measures within 2% of its deed area', () {
    final double area = GeoRules.areaSquareMeters(fixtureRing());
    expect(area, closeTo(162.23, 0.05));
    expect((area - 165.22).abs() / 165.22, lessThan(0.02));
  });

  test('a closed ring and an open ring measure the same', () {
    final List<LatLng> closed = fixtureRing();
    final List<LatLng> open = closed.sublist(0, closed.length - 1);
    expect(
      GeoRules.areaSquareMeters(open),
      closeTo(GeoRules.areaSquareMeters(closed), 1e-9),
    );
  });

  test('a tap inside a parcel hits it and a tap outside does not', () {
    final List<LatLng> ring = fixtureRing();
    expect(GeoRules.contains(ring, const LatLng(40.55885, 41.00088)), isTrue);
    expect(GeoRules.contains(ring, const LatLng(40.5600, 41.0020)), isFalse);
  });
}
