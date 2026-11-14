import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_parcel_label.dart';

/// The two stored layers: registry parcels (cyan) under the family's drawn
/// boundaries (orange), each shown only when its layer is on.
///
/// The [selection] is outlined in white and thicker. Labels — "114/1" or a
/// drawing's name — appear from [ParcelInfoDimens.parcelLabelMinZoom], where
/// there is room to read them; further out they would only cover the
/// imagery. A historical (inactive) registry parcel is dashed.
class MapParcelLayers extends StatelessWidget {
  const MapParcelLayers({
    super.key,
    required this.snapshot,
    required this.layers,
    required this.selection,
  });

  final MapSnapshotReadModel snapshot;

  final Set<MapLayerEnum> layers;

  final MapHitReadModel? selection;

  bool _isSelectedOfficial(OfficialParcelEntity parcel) =>
      selection is MapHitOfficial &&
      (selection! as MapHitOfficial).parcel.id == parcel.id;

  bool _isSelectedDrawing(DrawnParcelEntity drawing) =>
      selection is MapHitDrawn &&
      (selection! as MapHitDrawn).drawing.id == drawing.id;

  @override
  Widget build(BuildContext context) {
    final bool labels =
        MapCamera.of(context).zoom >= ParcelInfoDimens.parcelLabelMinZoom;
    final bool showOfficial = layers.contains(MapLayerEnum.official);
    final bool showDrawn = layers.contains(MapLayerEnum.drawn);
    return Stack(
      children: <Widget>[
        if (showOfficial)
          PolygonLayer(
            polygons: <Polygon>[
              for (final OfficialParcelEntity parcel in snapshot.officials)
                _polygon(
                  parcel.record.outline.corners,
                  ParcelInfoColor.officialStroke,
                  selected: _isSelectedOfficial(parcel),
                  dashed: !parcel.record.isActive,
                ),
            ],
          ),
        if (showDrawn)
          PolygonLayer(
            polygons: <Polygon>[
              for (final DrawnParcelEntity drawing in snapshot.drawings)
                _polygon(
                  drawing.outline.corners,
                  ParcelInfoColor.drawnStroke,
                  selected: _isSelectedDrawing(drawing),
                  dashed: false,
                ),
            ],
          ),
        if (labels)
          MarkerLayer(
            markers: <Marker>[
              if (showOfficial)
                for (final OfficialParcelEntity parcel in snapshot.officials)
                  _label(
                    parcel.record.outline.centre,
                    parcel.label,
                    ParcelInfoColor.officialStroke,
                  ),
              if (showDrawn)
                for (final DrawnParcelEntity drawing in snapshot.drawings)
                  _label(
                    drawing.outline.centre,
                    drawing.name,
                    ParcelInfoColor.drawnStroke,
                  ),
            ],
          ),
      ],
    );
  }

  Polygon _polygon(
    List<LatLng> corners,
    Color color, {
    required bool selected,
    required bool dashed,
  }) => Polygon(
    points: corners,
    color: color.withValues(alpha: ParcelInfoDimens.fillAlpha),
    borderColor: selected ? ParcelInfoColor.selectedStroke : color,
    borderStrokeWidth: selected
        ? ParcelInfoDimens.selectedOutline
        : ParcelInfoDimens.outline,
    pattern: dashed
        ? StrokePattern.dashed(
            segments: const <double>[
              ParcelInfoDimens.dash,
              ParcelInfoDimens.dash,
            ],
          )
        : const StrokePattern.solid(),
  );

  Marker _label(LatLng point, String text, Color accent) => Marker(
    point: point,
    width: ParcelInfoDimens.parcelLabelWidth,
    height: ParcelInfoDimens.parcelLabelHeight,
    child: IgnorePointer(child: MapParcelLabel(text, accent: accent)),
  );
}
