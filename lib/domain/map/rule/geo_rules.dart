import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/constants.dart';

/// Measurements on the WGS84 ellipsoid, at the scale of a parcel.
///
/// Corners are stored as WGS84 latitude/longitude — the system the official
/// registry answers in — and every length and area is computed from them here,
/// once, so the map, the panels and the stored record can never disagree.
///
/// A parcel is metres to a few hundred metres across, so the ellipsoid is
/// replaced by its tangent plane at the polygon's centre, scaled by the two
/// principal radii of curvature there: [meridianRadius] north–south and
/// [primeVerticalRadius] east–west. At this size the plane differs from the
/// ellipsoid by far less than a millimetre, which is well inside the precision
/// of any corner a person can tap — and unlike a spherical formula it does not
/// carry the 0.3% error of treating the earth as round.
///
/// [semiMajorAxis] and [flattening] are WGS84's own constants.
/// [toLocalPlane] gives each corner as metres east and north of the centre.
/// [areaSquareMeters] is the shoelace area of that plane polygon,
/// [perimeterMeters] and [edgeLengthsMeters] its sides, [distanceMeters] the
/// length between two points, and [contains] the ray-casting inside test the
/// map uses to answer "which parcel did I tap?" without asking the registry.
///
/// [metersPerPixel] converts a tap tolerance from screen pixels to the ground
/// at a zoom level, for snapping a corner to a reference vertex.
abstract final class GeoRules {
  static const double semiMajorAxis = 6378137;

  static const double flattening = 1 / 298.257223563;

  static const double _equatorMetersPerPixelAtZoomZero = 156543.03392804097;

  static double get _eccentricitySquared =>
      flattening * (CoreConstants.two - flattening);

  static double _sinSquared(double latitudeDegrees) => math
      .pow(math.sin(_radians(latitudeDegrees)), CoreConstants.two)
      .toDouble();

  static double meridianRadius(double latitudeDegrees) {
    final double s =
        CoreConstants.oneDouble -
        _eccentricitySquared * _sinSquared(latitudeDegrees);
    return semiMajorAxis *
        (CoreConstants.oneDouble - _eccentricitySquared) /
        math.pow(s, 1.5);
  }

  static double primeVerticalRadius(double latitudeDegrees) =>
      semiMajorAxis /
      math.sqrt(
        CoreConstants.oneDouble -
            _eccentricitySquared * _sinSquared(latitudeDegrees),
      );

  static LatLng centre(List<LatLng> points) {
    final List<LatLng> open = _open(points);
    if (open.isEmpty) {
      return const LatLng(CoreConstants.zeroDouble, CoreConstants.zeroDouble);
    }
    double latitude = CoreConstants.zeroDouble;
    double longitude = CoreConstants.zeroDouble;
    for (final LatLng point in open) {
      latitude += point.latitude;
      longitude += point.longitude;
    }
    return LatLng(latitude / open.length, longitude / open.length);
  }

  static List<math.Point<double>> toLocalPlane(
    List<LatLng> points,
    LatLng origin,
  ) {
    final double north = meridianRadius(origin.latitude);
    final double east =
        primeVerticalRadius(origin.latitude) *
        math.cos(_radians(origin.latitude));
    return <math.Point<double>>[
      for (final LatLng point in points)
        math.Point<double>(
          _radians(point.longitude - origin.longitude) * east,
          _radians(point.latitude - origin.latitude) * north,
        ),
    ];
  }

  static double areaSquareMeters(List<LatLng> points) {
    final List<LatLng> ring = _closed(points);
    if (ring.length <= _minimumCorners) return CoreConstants.zeroDouble;
    final List<math.Point<double>> plane = toLocalPlane(ring, centre(ring));
    double twiceArea = CoreConstants.zeroDouble;
    for (int i = CoreConstants.zero; i < plane.length - 1; i++) {
      twiceArea += plane[i].x * plane[i + 1].y - plane[i + 1].x * plane[i].y;
    }
    return twiceArea.abs() / CoreConstants.two;
  }

  static List<double> edgeLengthsMeters(List<LatLng> points) {
    final List<LatLng> ring = _closed(points);
    if (ring.length < CoreConstants.two) return <double>[];
    final List<math.Point<double>> plane = toLocalPlane(ring, centre(ring));
    return <double>[
      for (int i = CoreConstants.zero; i < plane.length - 1; i++)
        plane[i].distanceTo(plane[i + 1]),
    ];
  }

  static double perimeterMeters(List<LatLng> points) => edgeLengthsMeters(
    points,
  ).fold(CoreConstants.zeroDouble, (double sum, double edge) => sum + edge);

  static double distanceMeters(LatLng a, LatLng b) {
    final List<math.Point<double>> plane = toLocalPlane(<LatLng>[
      a,
      b,
    ], centre(<LatLng>[a, b]));
    return plane.first.distanceTo(plane.last);
  }

  static bool contains(List<LatLng> points, LatLng point) {
    final List<LatLng> ring = _closed(points);
    bool inside = false;
    for (
      int i = CoreConstants.zero, j = ring.length - 1;
      i < ring.length;
      j = i++
    ) {
      final LatLng a = ring[i];
      final LatLng b = ring[j];
      final bool crosses =
          (a.latitude > point.latitude) != (b.latitude > point.latitude) &&
          point.longitude <
              (b.longitude - a.longitude) *
                      (point.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude;
      if (crosses) inside = !inside;
    }
    return inside;
  }

  static double metersPerPixel({
    required double latitudeDegrees,
    required double zoom,
  }) =>
      _equatorMetersPerPixelAtZoomZero *
      math.cos(_radians(latitudeDegrees)) /
      math.pow(CoreConstants.two, zoom);

  static const int _minimumCorners = 3;

  static double _radians(double degrees) => degrees * math.pi / 180;

  static List<LatLng> _open(List<LatLng> points) =>
      points.length > CoreConstants.one && points.first == points.last
      ? points.sublist(CoreConstants.zero, points.length - 1)
      : points;

  static List<LatLng> _closed(List<LatLng> points) =>
      points.isEmpty || points.first == points.last
      ? points
      : <LatLng>[...points, points.first];
}
