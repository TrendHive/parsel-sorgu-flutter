import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';

double _dms(int degrees, int minutes, double seconds) =>
    degrees.sign * (degrees.abs() + minutes / 60 + seconds / 3600);

void main() {
  test(
    "side lengths match the surveyors' reference line to the millimetre",
    () {
      final LatLng flindersPeak = LatLng(
        _dms(-37, 57, 3.72030),
        _dms(144, 25, 29.52440),
      );
      final LatLng buninyong = LatLng(
        _dms(-37, 39, 10.15610),
        _dms(143, 55, 35.38390),
      );
      expect(
        GeoRules.geodesicMeters(flindersPeak, buninyong),
        closeTo(54972.271, 0.001),
      );
    },
  );

  test('a square parcel has the side lengths of its corners', () {
    const List<LatLng> square = <LatLng>[
      LatLng(40, 41),
      LatLng(40, 41.001),
      LatLng(40.001, 41.001),
      LatLng(40.001, 41),
    ];
    final List<double> sides = GeoRules.edgeLengthsMeters(square);
    expect(sides, hasLength(4));
    expect(sides[0], closeTo(85.394, 0.001));
    expect(sides[1], closeTo(111.035, 0.001));
    expect(sides[2], closeTo(85.393, 0.001));
    expect(sides[3], closeTo(111.035, 0.001));
    expect(GeoRules.geodesicMeters(square.first, square.first), 0);
  });
}
