import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_merge_read_model.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';

/// A merge in progress, drawn over the map: every chosen piece outlined in
/// the draft colour, then — once they join — the merged shape filled.
class MapMergeLayer extends StatelessWidget {
  const MapMergeLayer({super.key, required this.merge});

  final MapMergeReadModel merge;

  @override
  Widget build(BuildContext context) {
    final List<LatLng>? outline = merge.outline;
    return PolygonLayer(
      polygons: <Polygon>[
        for (final DrawnParcelEntity drawing in merge.drawings)
          Polygon(
            points: drawing.outline.corners,
            borderColor: ParcelInfoColor.draftStroke,
            borderStrokeWidth: ParcelInfoDimens.outline,
          ),
        if (outline != null)
          Polygon(
            points: outline,
            color: ParcelInfoColor.branch(0)
                .withValues(alpha: ParcelInfoDimens.branchFillAlpha),
            borderColor: ParcelInfoColor.branch(0),
            borderStrokeWidth: ParcelInfoDimens.drawingOutline,
          ),
      ],
    );
  }
}
