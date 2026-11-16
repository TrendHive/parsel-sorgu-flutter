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
///
/// [fromLocalPlane] is the way back from metres to latitude/longitude.
/// [nearestOnRing] is the closest point of an outline's sides to a point, so
/// a corner can sit exactly on a neighbour's boundary. [overlapSquareMeters]
/// estimates the area two outlines share by sampling a grid over the box
/// they have in common — sides that merely touch share nothing.
///
/// [splitByLine] cuts an outline along the straight line through two points
/// and answers the two pieces, or nothing when the line does not divide it.
/// [splitEqual] cuts it into strips of equal area across its long axis.
///
/// [redivide] moves the line between two neighbouring outlines: it joins
/// them along the sides they share (corners lying on the other's side
/// count), then cuts the whole again with a straight line parallel to the
/// old dividing line, placed so the first piece has `firstShare` of the
/// area. The outer boundary is kept exactly. It answers nothing when the two
/// do not share a side.
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

  static List<LatLng> fromLocalPlane(
    List<math.Point<double>> points,
    LatLng origin,
  ) {
    final double north = meridianRadius(origin.latitude);
    final double east =
        primeVerticalRadius(origin.latitude) *
        math.cos(_radians(origin.latitude));
    return <LatLng>[
      for (final math.Point<double> point in points)
        LatLng(
          origin.latitude + _degrees(point.y / north),
          origin.longitude + _degrees(point.x / east),
        ),
    ];
  }

  static ({LatLng point, double distanceMeters})? nearestOnRing(
    List<LatLng> points,
    LatLng target,
  ) {
    final List<LatLng> ring = _closed(points);
    if (ring.length < CoreConstants.two) return null;
    final List<math.Point<double>> plane = toLocalPlane(ring, target);
    const math.Point<double> origin = math.Point<double>(
      CoreConstants.zeroDouble,
      CoreConstants.zeroDouble,
    );
    math.Point<double>? best;
    double bestDistance = double.infinity;
    for (int i = CoreConstants.zero; i < plane.length - 1; i++) {
      final math.Point<double> candidate = _closestOnSegment(
        plane[i],
        plane[i + 1],
        origin,
      );
      final double distance = candidate.distanceTo(origin);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = candidate;
      }
    }
    if (best == null) return null;
    return (
      point: fromLocalPlane(<math.Point<double>>[best], target).single,
      distanceMeters: bestDistance,
    );
  }

  static double overlapSquareMeters(
    List<LatLng> first,
    List<LatLng> second, {
    int grid = _overlapGrid,
  }) {
    final List<LatLng> a = _open(first);
    final List<LatLng> b = _open(second);
    if (a.length < _minimumCorners || b.length < _minimumCorners) {
      return CoreConstants.zeroDouble;
    }
    final LatLng origin = centre(a);
    final List<math.Point<double>> planeA = toLocalPlane(a, origin);
    final List<math.Point<double>> planeB = toLocalPlane(b, origin);
    final double left = math.max(_minX(planeA), _minX(planeB));
    final double right = math.min(_maxX(planeA), _maxX(planeB));
    final double bottom = math.max(_minY(planeA), _minY(planeB));
    final double top = math.min(_maxY(planeA), _maxY(planeB));
    if (right <= left || top <= bottom) return CoreConstants.zeroDouble;
    final double stepX = (right - left) / grid;
    final double stepY = (top - bottom) / grid;
    int shared = CoreConstants.zero;
    for (int i = CoreConstants.zero; i < grid; i++) {
      for (int j = CoreConstants.zero; j < grid; j++) {
        final math.Point<double> sample = math.Point<double>(
          left + (i + _half) * stepX,
          bottom + (j + _half) * stepY,
        );
        if (_inside(planeA, sample) && _inside(planeB, sample)) shared++;
      }
    }
    return shared * stepX * stepY;
  }

  static List<List<LatLng>> splitByLine(
    List<LatLng> points,
    LatLng from,
    LatLng to,
  ) {
    final List<LatLng> open = _open(points);
    if (open.length < _minimumCorners || from == to) return <List<LatLng>>[];
    final LatLng origin = centre(open);
    final List<math.Point<double>> plane = toLocalPlane(open, origin);
    final List<math.Point<double>> line = toLocalPlane(<LatLng>[
      from,
      to,
    ], origin);
    final List<List<math.Point<double>>> pieces = <List<math.Point<double>>>[
      _clip(plane, line.first, line.last),
      _clip(plane, line.last, line.first),
    ];
    final double whole = _planeArea(plane);
    if (pieces.any(
      (List<math.Point<double>> piece) =>
          piece.length < _minimumCorners ||
          _planeArea(piece) < whole * _smallestPiece,
    )) {
      return <List<LatLng>>[];
    }
    return <List<LatLng>>[
      for (final List<math.Point<double>> piece in pieces)
        fromLocalPlane(piece, origin),
    ];
  }

  static List<List<LatLng>> splitEqual(List<LatLng> points, int pieces) {
    final List<LatLng> open = _open(points);
    if (open.length < _minimumCorners || pieces < CoreConstants.two) {
      return <List<LatLng>>[];
    }
    final LatLng origin = centre(open);
    final double angle = _longAxisAngle(toLocalPlane(open, origin));
    final List<math.Point<double>> turned = _rotate(
      toLocalPlane(open, origin),
      -angle,
    );
    final double whole = _planeArea(turned);
    final List<double> cuts = <double>[
      _minX(turned),
      for (int k = CoreConstants.one; k < pieces; k++)
        _cutAt(turned, whole * k / pieces),
      _maxX(turned),
    ];
    final List<List<LatLng>> strips = <List<LatLng>>[];
    for (int k = CoreConstants.zero; k < pieces; k++) {
      final List<math.Point<double>> strip = _rightOf(
        _leftOf(turned, cuts[k + 1]),
        cuts[k],
      );
      if (strip.length < _minimumCorners) return <List<LatLng>>[];
      strips.add(fromLocalPlane(_rotate(strip, angle), origin));
    }
    return strips;
  }

  static ({List<LatLng> first, List<LatLng> second})? redivide(
    List<LatLng> first,
    List<LatLng> second,
    double firstShare,
  ) {
    final List<LatLng> a = _open(first);
    final List<LatLng> b = _open(second);
    if (a.length < _minimumCorners ||
        b.length < _minimumCorners ||
        firstShare <= CoreConstants.zeroDouble ||
        firstShare >= CoreConstants.oneDouble) {
      return null;
    }
    final LatLng origin = centre(<LatLng>[...a, ...b]);
    List<math.Point<double>> planeA = _counterClockwise(
      toLocalPlane(a, origin),
    );
    List<math.Point<double>> planeB = _counterClockwise(
      toLocalPlane(b, origin),
    );
    planeA = _withCornersOf(planeA, planeB);
    planeB = _withCornersOf(planeB, planeA);
    final ({List<math.Point<double>> ring, List<math.Point<double>> shared})?
    joined = _join(planeA, planeB);
    if (joined == null) return null;
    math.Point<double> from = joined.shared.first;
    math.Point<double> to = joined.shared.last;
    for (final math.Point<double> p in joined.shared) {
      for (final math.Point<double> q in joined.shared) {
        if (p.distanceTo(q) > from.distanceTo(to)) {
          from = p;
          to = q;
        }
      }
    }
    final double length = from.distanceTo(to);
    if (length <= _joinTolerance) return null;
    final math.Point<double> along = math.Point<double>(
      (to.x - from.x) / length,
      (to.y - from.y) / length,
    );
    final math.Point<double> normal = math.Point<double>(-along.y, along.x);
    double offset(math.Point<double> p) =>
        (p.x - from.x) * normal.x + (p.y - from.y) * normal.y;
    final double sideOfFirst =
        planeA.map(offset).reduce((double x, double y) => x + y) /
        planeA.length;
    List<math.Point<double>> firstSide(double t) {
      final math.Point<double> start = math.Point<double>(
        from.x + normal.x * t,
        from.y + normal.y * t,
      );
      final math.Point<double> end = math.Point<double>(
        start.x + along.x,
        start.y + along.y,
      );
      return sideOfFirst >= CoreConstants.zeroDouble
          ? _clip(joined.ring, start, end)
          : _clip(joined.ring, end, start);
    }

    List<math.Point<double>> secondSide(double t) {
      final math.Point<double> start = math.Point<double>(
        from.x + normal.x * t,
        from.y + normal.y * t,
      );
      final math.Point<double> end = math.Point<double>(
        start.x + along.x,
        start.y + along.y,
      );
      return sideOfFirst >= CoreConstants.zeroDouble
          ? _clip(joined.ring, end, start)
          : _clip(joined.ring, start, end);
    }

    final double target = _planeArea(joined.ring) * firstShare;
    final Iterable<double> offsets = joined.ring.map(offset);
    double low = offsets.reduce(math.min);
    double high = offsets.reduce(math.max);
    final bool growsWithT = sideOfFirst < CoreConstants.zeroDouble;
    for (int i = CoreConstants.zero; i < _bisections; i++) {
      final double middle = (low + high) / CoreConstants.two;
      final bool tooSmall = _planeArea(firstSide(middle)) < target;
      if (tooSmall == growsWithT) {
        low = middle;
      } else {
        high = middle;
      }
    }
    final double t = (low + high) / CoreConstants.two;
    final List<math.Point<double>> pieceA = firstSide(t);
    final List<math.Point<double>> pieceB = secondSide(t);
    if (pieceA.length < _minimumCorners || pieceB.length < _minimumCorners) {
      return null;
    }
    return (
      first: fromLocalPlane(pieceA, origin),
      second: fromLocalPlane(pieceB, origin),
    );
  }

  static List<math.Point<double>> _counterClockwise(
    List<math.Point<double>> plane,
  ) {
    double twice = CoreConstants.zeroDouble;
    for (int i = CoreConstants.zero; i < plane.length; i++) {
      final math.Point<double> a = plane[i];
      final math.Point<double> b = plane[(i + 1) % plane.length];
      twice += a.x * b.y - b.x * a.y;
    }
    return twice >= CoreConstants.zeroDouble ? plane : plane.reversed.toList();
  }

  static List<math.Point<double>> _withCornersOf(
    List<math.Point<double>> ring,
    List<math.Point<double>> other,
  ) {
    final List<math.Point<double>> result = <math.Point<double>>[];
    for (int i = CoreConstants.zero; i < ring.length; i++) {
      final math.Point<double> a = ring[i];
      final math.Point<double> b = ring[(i + 1) % ring.length];
      result.add(a);
      final double lengthSquared =
          (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y);
      final List<({double t, math.Point<double> point})> inside =
          <({double t, math.Point<double> point})>[
            for (final math.Point<double> p in other)
              if (p.distanceTo(a) > _joinTolerance &&
                  p.distanceTo(b) > _joinTolerance &&
                  _closestOnSegment(a, b, p).distanceTo(p) <= _joinTolerance)
                (
                  t:
                      ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) /
                      lengthSquared,
                  point: p,
                ),
          ]..sort(
            (
              ({double t, math.Point<double> point}) x,
              ({double t, math.Point<double> point}) y,
            ) => x.t.compareTo(y.t),
          );
      result.addAll(
        inside.map(
          (({double t, math.Point<double> point}) entry) => entry.point,
        ),
      );
    }
    return result;
  }

  static ({List<math.Point<double>> ring, List<math.Point<double>> shared})?
  _join(List<math.Point<double>> a, List<math.Point<double>> b) {
    bool same(math.Point<double> p, math.Point<double> q) =>
        p.distanceTo(q) <= _joinTolerance;
    List<(math.Point<double>, math.Point<double>)> edgesOf(
      List<math.Point<double>> ring,
    ) => <(math.Point<double>, math.Point<double>)>[
      for (int i = CoreConstants.zero; i < ring.length; i++)
        (ring[i], ring[(i + 1) % ring.length]),
    ];
    final List<(math.Point<double>, math.Point<double>)> edgesA = edgesOf(a);
    final List<(math.Point<double>, math.Point<double>)> edgesB = edgesOf(b);
    bool reversedIn(
      (math.Point<double>, math.Point<double>) edge,
      List<(math.Point<double>, math.Point<double>)> edges,
    ) => edges.any(
      ((math.Point<double>, math.Point<double>) other) =>
          same(edge.$1, other.$2) && same(edge.$2, other.$1),
    );
    final List<math.Point<double>> shared = <math.Point<double>>[
      for (final (math.Point<double>, math.Point<double>) edge in edgesA)
        if (reversedIn(edge, edgesB)) ...<math.Point<double>>[edge.$1, edge.$2],
    ];
    if (shared.isEmpty) return null;
    final List<(math.Point<double>, math.Point<double>)> outer =
        <(math.Point<double>, math.Point<double>)>[
          for (final (math.Point<double>, math.Point<double>) edge in edgesA)
            if (!reversedIn(edge, edgesB)) edge,
          for (final (math.Point<double>, math.Point<double>) edge in edgesB)
            if (!reversedIn(edge, edgesA)) edge,
        ];
    if (outer.isEmpty) return null;
    final List<math.Point<double>> ring = <math.Point<double>>[];
    final List<(math.Point<double>, math.Point<double>)> left =
        <(math.Point<double>, math.Point<double>)>[...outer];
    (math.Point<double>, math.Point<double>) current = left.removeAt(
      CoreConstants.zero,
    );
    ring.add(current.$1);
    while (left.isNotEmpty) {
      final int next = left.indexWhere(
        ((math.Point<double>, math.Point<double>) edge) =>
            same(edge.$1, current.$2),
      );
      if (next < CoreConstants.zero) return null;
      current = left.removeAt(next);
      ring.add(current.$1);
    }
    if (!same(current.$2, ring.first)) return null;
    return (ring: _distinct(ring), shared: shared);
  }

  static double _cutAt(List<math.Point<double>> plane, double area) {
    double low = _minX(plane);
    double high = _maxX(plane);
    for (int i = CoreConstants.zero; i < _bisections; i++) {
      final double middle = (low + high) / CoreConstants.two;
      if (_planeArea(_leftOf(plane, middle)) < area) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return (low + high) / CoreConstants.two;
  }

  static List<math.Point<double>> _leftOf(
    List<math.Point<double>> plane,
    double x,
  ) => _clip(
    plane,
    math.Point<double>(x, CoreConstants.zeroDouble),
    math.Point<double>(x, CoreConstants.oneDouble),
  );

  static List<math.Point<double>> _rightOf(
    List<math.Point<double>> plane,
    double x,
  ) => _clip(
    plane,
    math.Point<double>(x, CoreConstants.oneDouble),
    math.Point<double>(x, CoreConstants.zeroDouble),
  );

  static List<math.Point<double>> _clip(
    List<math.Point<double>> plane,
    math.Point<double> from,
    math.Point<double> to,
  ) {
    double side(math.Point<double> p) =>
        (to.x - from.x) * (p.y - from.y) - (to.y - from.y) * (p.x - from.x);
    final List<math.Point<double>> kept = <math.Point<double>>[];
    for (int i = CoreConstants.zero; i < plane.length; i++) {
      final math.Point<double> current = plane[i];
      final math.Point<double> next = plane[(i + 1) % plane.length];
      final double a = side(current);
      final double b = side(next);
      if (a >= CoreConstants.zeroDouble) kept.add(current);
      if ((a > CoreConstants.zeroDouble && b < CoreConstants.zeroDouble) ||
          (a < CoreConstants.zeroDouble && b > CoreConstants.zeroDouble)) {
        final double t = a / (a - b);
        kept.add(
          math.Point<double>(
            current.x + (next.x - current.x) * t,
            current.y + (next.y - current.y) * t,
          ),
        );
      }
    }
    return _distinct(kept);
  }

  static List<math.Point<double>> _distinct(List<math.Point<double>> points) {
    final List<math.Point<double>> result = <math.Point<double>>[];
    for (final math.Point<double> point in points) {
      if (result.isEmpty || result.last.distanceTo(point) > _samePoint) {
        result.add(point);
      }
    }
    if (result.length > CoreConstants.one &&
        result.first.distanceTo(result.last) <= _samePoint) {
      result.removeLast();
    }
    return result;
  }

  static double _longAxisAngle(List<math.Point<double>> plane) {
    double xx = CoreConstants.zeroDouble;
    double yy = CoreConstants.zeroDouble;
    double xy = CoreConstants.zeroDouble;
    for (final math.Point<double> p in plane) {
      xx += p.x * p.x;
      yy += p.y * p.y;
      xy += p.x * p.y;
    }
    return math.atan2(CoreConstants.two * xy, xx - yy) / CoreConstants.two;
  }

  static List<math.Point<double>> _rotate(
    List<math.Point<double>> plane,
    double angle,
  ) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return <math.Point<double>>[
      for (final math.Point<double> p in plane)
        math.Point<double>(p.x * c - p.y * s, p.x * s + p.y * c),
    ];
  }

  static double _planeArea(List<math.Point<double>> plane) {
    double twice = CoreConstants.zeroDouble;
    for (int i = CoreConstants.zero; i < plane.length; i++) {
      final math.Point<double> a = plane[i];
      final math.Point<double> b = plane[(i + 1) % plane.length];
      twice += a.x * b.y - b.x * a.y;
    }
    return twice.abs() / CoreConstants.two;
  }

  static bool _inside(List<math.Point<double>> plane, math.Point<double> p) {
    bool inside = false;
    for (
      int i = CoreConstants.zero, j = plane.length - 1;
      i < plane.length;
      j = i++
    ) {
      final math.Point<double> a = plane[i];
      final math.Point<double> b = plane[j];
      if ((a.y > p.y) != (b.y > p.y) &&
          p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
        inside = !inside;
      }
    }
    return inside;
  }

  static math.Point<double> _closestOnSegment(
    math.Point<double> a,
    math.Point<double> b,
    math.Point<double> p,
  ) {
    final double dx = b.x - a.x;
    final double dy = b.y - a.y;
    final double lengthSquared = dx * dx + dy * dy;
    if (lengthSquared == CoreConstants.zeroDouble) return a;
    final double t = (((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared)
        .clamp(CoreConstants.zeroDouble, CoreConstants.oneDouble);
    return math.Point<double>(a.x + dx * t, a.y + dy * t);
  }

  static double _minX(List<math.Point<double>> plane) =>
      plane.map((math.Point<double> p) => p.x).reduce(math.min);

  static double _maxX(List<math.Point<double>> plane) =>
      plane.map((math.Point<double> p) => p.x).reduce(math.max);

  static double _minY(List<math.Point<double>> plane) =>
      plane.map((math.Point<double> p) => p.y).reduce(math.min);

  static double _maxY(List<math.Point<double>> plane) =>
      plane.map((math.Point<double> p) => p.y).reduce(math.max);

  static const int _minimumCorners = 3;

  static const double _joinTolerance = 0.05;

  static const int _overlapGrid = 48;

  static const int _bisections = 48;

  static const double _half = 0.5;

  static const double _samePoint = 0.001;

  static const double _smallestPiece = 0.001;

  static double _degrees(double radians) => radians * 180 / math.pi;

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
