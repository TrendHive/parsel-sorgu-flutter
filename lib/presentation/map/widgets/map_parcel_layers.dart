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
/// boundaries, each shown only when its layer is on.
///
/// The [selection] is outlined in white and thicker. Labels — "114/1" or a
/// drawing's name — appear from [ParcelInfoDimens.parcelLabelMinZoom], where
/// there is room to read them; further out they would only cover the
/// imagery. A historical (inactive) registry parcel is dashed.
///
/// The drawn layer is coloured by owner: one colour per person recorded as
/// an owner, one for a drawing several people share, and a neutral grey for
/// one nobody owns yet — filled strongly, so ownership reads at a glance.
/// With a [colourLevel] it is coloured by branch of the family at that
/// level of the tree instead. A registry parcel whose real boundaries have
/// owners takes their colour too, so ownership shows with only the registry
/// layer on; one nobody holds keeps the registry's cyan.
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

  Color _colourOf(DrawnParcelEntity drawing, List<PersonEntity> branches) =>
      _colourFor(
        snapshot.holdersAt(drawing, colourLevel),
        branches,
        ParcelInfoColor.unowned,
      );

  Color _officialColour(
    OfficialParcelEntity parcel,
    List<PersonEntity> branches,
  ) => _colourFor(
    snapshot.officialHoldersAt(parcel, colourLevel),
    branches,
    ParcelInfoColor.officialStroke,
  );

  Color _colourFor(
    Set<String> holders,
    List<PersonEntity> branches,
    Color nobody,
  ) {
    if (holders.isEmpty) return nobody;
    if (holders.length > 1) return ParcelInfoColor.sharedBranches;
    return ParcelInfoColor.branch(
      branches.indexWhere((PersonEntity p) => p.id == holders.single),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PersonEntity> branches = snapshot.branchesAt(colourLevel);
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
                if (_officialColour(parcel, branches) case final Color colour)
                  _polygon(
                    parcel.record.outline.corners,
                    colour,
                    selected: _isSelectedOfficial(parcel),
                    dashed: !parcel.record.isActive,
                    alpha: colour == ParcelInfoColor.officialStroke
                        ? ParcelInfoDimens.fillAlpha
                        : ParcelInfoDimens.branchFillAlpha,
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
                  alpha: ParcelInfoDimens.branchFillAlpha,
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
                    _officialColour(parcel, branches),
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
