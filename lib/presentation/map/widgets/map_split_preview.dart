import 'dart:math' as math;

import 'package:latlong2/latlong.dart' show LatLng;
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';

/// A small sketch of a drawing and the pieces an equal split would make,
/// north up, each piece numbered in the order it is given out.
///
/// [outline] is the drawing's corners and [pieces] the strips; an arrow in
/// the corner marks north.
class MapSplitPreview extends StatelessWidget {
  const MapSplitPreview({
    super.key,
    required this.outline,
    required this.pieces,
  });

  final List<LatLng> outline;

  final List<List<LatLng>> pieces;

  static const double height = 200;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colours = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _SplitPainter(
                outline: outline,
                pieces: pieces,
                fill: colours.primary,
                stroke: colours.onSurface,
                label: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: colours.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.north, color: colours.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SplitPainter extends CustomPainter {
  _SplitPainter({
    required this.outline,
    required this.pieces,
    required this.fill,
    required this.stroke,
    required this.label,
  });

  final List<LatLng> outline;

  final List<List<LatLng>> pieces;

  final Color fill;

  final Color stroke;

  final TextStyle label;

  static const int _minimumCorners = 3;
  static const double _margin = 12;
  static const double _half = 0.5;
  static const double _strongFill = 0.45;
  static const double _weakFill = 0.18;

  @override
  void paint(Canvas canvas, Size size) {
    if (outline.length < _minimumCorners) return;
    final LatLng origin = GeoRules.centre(outline);
    final List<math.Point<double>> ring = GeoRules.toLocalPlane(
      outline,
      origin,
    );
    final double minX = ring
        .map((math.Point<double> p) => p.x)
        .reduce(math.min);
    final double maxX = ring
        .map((math.Point<double> p) => p.x)
        .reduce(math.max);
    final double minY = ring
        .map((math.Point<double> p) => p.y)
        .reduce(math.min);
    final double maxY = ring
        .map((math.Point<double> p) => p.y)
        .reduce(math.max);
    final double spanX = math.max(maxX - minX, CoreConstants.oneDouble);
    final double spanY = math.max(maxY - minY, CoreConstants.oneDouble);
    final double scale = math.min(
      (size.width - _margin * CoreConstants.two) / spanX,
      (size.height - _margin * CoreConstants.two) / spanY,
    );
    final Offset shift = Offset(
      (size.width - spanX * scale) / CoreConstants.two,
      (size.height - spanY * scale) / CoreConstants.two,
    );
    Offset toScreen(math.Point<double> p) =>
        Offset((p.x - minX) * scale, (maxY - p.y) * scale) + shift;
    Path pathOf(List<math.Point<double>> points) =>
        Path()..addPolygon(points.map(toScreen).toList(), true);

    for (final (int index, List<LatLng> piece) in pieces.indexed) {
      final List<math.Point<double>> plane = GeoRules.toLocalPlane(
        piece,
        origin,
      );
      final Path path = pathOf(plane);
      canvas
        ..drawPath(
          path,
          Paint()
            ..color = fill.withValues(
              alpha: index.isEven ? _strongFill : _weakFill,
            ),
        )
        ..drawPath(
          path,
          Paint()
            ..color = stroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = ParcelInfoDimens.outline / CoreConstants.two,
        );
      final Offset middle = toScreen(
        math.Point<double>(
          plane.map((math.Point<double> p) => p.x).reduce((a, b) => a + b) /
              plane.length,
          plane.map((math.Point<double> p) => p.y).reduce((a, b) => a + b) /
              plane.length,
        ),
      );
      final TextPainter number = TextPainter(
        text: TextSpan(text: '${index + CoreConstants.one}', style: label),
        textDirection: TextDirection.ltr,
      )..layout();
      number.paint(
        canvas,
        middle - Offset(number.width, number.height) * _half,
      );
    }
    canvas.drawPath(
      pathOf(ring),
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = ParcelInfoDimens.outline,
    );
  }

  @override
  bool shouldRepaint(_SplitPainter old) =>
      old.pieces != pieces || old.outline != outline || old.fill != fill;
}
