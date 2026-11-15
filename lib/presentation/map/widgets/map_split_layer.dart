import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_split_read_model.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';

/// A cut in progress, drawn over the map: the drawing being cut, the points
/// tapped so far, the cut line through them and — once the line divides the
/// drawing — the two pieces in two colours.
class MapSplitLayer extends StatelessWidget {
  const MapSplitLayer({super.key, required this.split});

  final MapSplitReadModel split;

  static const int _cutPoints = 2;

  static const double _reach = 4;

  List<LatLng> get _line {
    final LatLng a = split.points.first;
    final LatLng b = split.points.last;
    final double dLat = (b.latitude - a.latitude) * _reach;
    final double dLng = (b.longitude - a.longitude) * _reach;
    return <LatLng>[
      LatLng(a.latitude - dLat, a.longitude - dLng),
      LatLng(b.latitude + dLat, b.longitude + dLng),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<List<LatLng>> pieces = split.pieces;
    return Stack(
      children: <Widget>[
        PolygonLayer(
          polygons: <Polygon>[
            if (pieces.isEmpty)
              _polygon(
                split.drawing.outline.corners,
                ParcelInfoColor.draftStroke,
              ),
            for (final (int index, List<LatLng> piece) in pieces.indexed)
              _polygon(piece, ParcelInfoColor.branch(index)),
          ],
        ),
        if (split.points.length >= _cutPoints)
          PolylineLayer(
            polylines: <Polyline>[
              Polyline(
                points: _line,
                color: ParcelInfoColor.selectedStroke,
                strokeWidth: ParcelInfoDimens.drawingOutline,
                pattern: StrokePattern.dashed(
                  segments: const <double>[
                    ParcelInfoDimens.dash,
                    ParcelInfoDimens.dash,
                  ],
                ),
              ),
            ],
          ),
        MarkerLayer(
          markers: <Marker>[
            for (final LatLng point in split.points)
              Marker(
                point: point,
                width: ParcelInfoDimens.cutPoint,
                height: ParcelInfoDimens.cutPoint,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ParcelInfoColor.handleSelected,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: ParcelInfoColor.handleFill),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Polygon _polygon(List<LatLng> corners, Color colour) => Polygon(
    points: corners,
    color: colour.withValues(alpha: ParcelInfoDimens.branchFillAlpha),
    borderColor: colour,
    borderStrokeWidth: ParcelInfoDimens.drawingOutline,
  );
}
