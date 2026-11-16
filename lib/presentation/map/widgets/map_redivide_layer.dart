import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_redivide_read_model.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';

/// A re-division in progress, drawn over the map: the drawing it started
/// from (and the neighbour, once tapped) outlined in the draft colour, then
/// — when the deeds allow it — the two new shapes in two colours.
class MapRedivideLayer extends StatelessWidget {
  const MapRedivideLayer({super.key, required this.redivide});

  final MapRedivideReadModel redivide;

  @override
  Widget build(BuildContext context) {
    final ({List<LatLng> first, List<LatLng> second})? pieces = redivide.pieces;
    return PolygonLayer(
      polygons: <Polygon>[
        if (pieces == null) ...<Polygon>[
          _polygon(redivide.first.outline.corners, ParcelInfoColor.draftStroke),
          if (redivide.second != null)
            _polygon(
              redivide.second!.outline.corners,
              ParcelInfoColor.draftStroke,
            ),
        ] else ...<Polygon>[
          _polygon(pieces.first, ParcelInfoColor.branch(0)),
          _polygon(pieces.second, ParcelInfoColor.branch(1)),
        ],
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
