import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_parcel_label.dart';

/// The two stored layers: registry parcels (cyan) under the family's drawn
/// boundaries (orange), each shown only when its layer is on.
///
/// The [selection] is outlined in white and thicker. Labels — "114/1" or a
/// drawing's name — appear from [ParcelInfoDimens.parcelLabelMinZoom], where
/// there is room to read them; further out they would only cover the
/// imagery. A historical (inactive) registry parcel is dashed.
///
/// With a [colourLevel] the drawn layer is coloured by branch of the family
/// at that level of the tree instead: one colour per branch, a neutral one
/// for a drawing several branches share, the usual orange for one nobody
/// owns yet — and filled more strongly, so the branches read at a glance.
class MapParcelLayers extends StatelessWidget {
  const MapParcelLayers({
    super.key,
    required this.snapshot,
    required this.layers,
    required this.selection,
    this.colourLevel,
  });

  final MapSnapshotReadModel snapshot;

  final Set<MapLayerEnum> layers;

  final MapHitReadModel? selection;

  final int? colourLevel;

  bool _isSelectedOfficial(OfficialParcelEntity parcel) =>
      selection is MapHitOfficial &&
      (selection! as MapHitOfficial).parcel.id == parcel.id;

  bool _isSelectedDrawing(DrawnParcelEntity drawing) =>
      selection is MapHitDrawn &&
      (selection! as MapHitDrawn).drawing.id == drawing.id;

  Color _colourOf(DrawnParcelEntity drawing, List<PersonEntity> branches) {
    final int? level = colourLevel;
    if (level == null) return ParcelInfoColor.drawnStroke;
    final Set<String> holders = snapshot.holdersAt(drawing, level);
    if (holders.isEmpty) return ParcelInfoColor.drawnStroke;
    if (holders.length > 1) return ParcelInfoColor.sharedBranches;
    return ParcelInfoColor.branch(
      branches.indexWhere((PersonEntity p) => p.id == holders.single),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PersonEntity> branches = colourLevel == null
        ? const <PersonEntity>[]
        : snapshot.branchesAt(colourLevel!);
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
                  _colourOf(drawing, branches),
                  selected: _isSelectedDrawing(drawing),
                  dashed: false,
                  alpha: colourLevel == null
                      ? ParcelInfoDimens.fillAlpha
                      : ParcelInfoDimens.branchFillAlpha,
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
                    _colourOf(drawing, branches),
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
    double alpha = ParcelInfoDimens.fillAlpha,
  }) => Polygon(
    points: corners,
    color: color.withValues(alpha: alpha),
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
