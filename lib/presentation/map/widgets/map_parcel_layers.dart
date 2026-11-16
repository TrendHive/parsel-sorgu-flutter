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
import 'package:parcel_atlas/presentation/map/widgets/map_owner_avatars.dart';
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
/// an owner, one for a drawing several people share — filled strongly, with
/// a round avatar of each holder's initials above its label — while one
/// nobody owns yet is drawn faintly in grey, so owned land stands out.
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

  Color _colourFor(
    Set<String> holders,
    List<PersonEntity> branches,
    Color nobody,
  ) {
    if (holders.isEmpty) return nobody;
    if (holders.length > 1) return ParcelInfoColor.sharedBranches;
    return _branchColour(holders.single, branches);
  }

  Color _branchColour(String personId, List<PersonEntity> branches) =>
      ParcelInfoColor.branch(
        branches.indexWhere((PersonEntity p) => p.id == personId),
      );

  List<({String initials, Color colour})> _avatars(
    Set<String> holders,
    List<PersonEntity> branches,
  ) => <({String initials, Color colour})>[
    for (final PersonEntity person in branches)
      if (holders.contains(person.id))
        (initials: person.initials, colour: _branchColour(person.id, branches)),
  ];

  @override
  Widget build(BuildContext context) {
    final List<PersonEntity> branches = snapshot.branchesAt(colourLevel);
    final bool labels =
        MapCamera.of(context).zoom >= ParcelInfoDimens.parcelLabelMinZoom;
    final bool showOfficial = layers.contains(MapLayerEnum.official);
    final bool showDrawn = layers.contains(MapLayerEnum.drawn);
    final List<
      ({LatLng centre, String label, Set<String> holders, Color nobody})
    >
    shown =
        <({LatLng centre, String label, Set<String> holders, Color nobody})>[
          if (showOfficial)
            for (final OfficialParcelEntity parcel in snapshot.officials)
              (
                centre: parcel.record.outline.centre,
                label: parcel.label,
                holders: snapshot.officialHoldersAt(parcel, colourLevel),
                nobody: ParcelInfoColor.officialStroke,
              ),
          if (showDrawn)
            for (final DrawnParcelEntity drawing in snapshot.drawings)
              (
                centre: drawing.outline.centre,
                label: drawing.name,
                holders: snapshot.holdersAt(drawing, colourLevel),
                nobody: ParcelInfoColor.unowned,
              ),
        ];
    return Stack(
      children: <Widget>[
        if (showOfficial)
          PolygonLayer(
            polygons: <Polygon>[
              for (final OfficialParcelEntity parcel in snapshot.officials)
                if (snapshot.officialHoldersAt(parcel, colourLevel)
                    case final Set<String> holders)
                  _polygon(
                    parcel.record.outline.corners,
                    _colourFor(
                      holders,
                      branches,
                      ParcelInfoColor.officialStroke,
                    ),
                    selected: _isSelectedOfficial(parcel),
                    dashed: !parcel.record.isActive,
                    owned: holders.isNotEmpty,
                  ),
            ],
          ),
        if (showDrawn)
          PolygonLayer(
            polygons: <Polygon>[
              for (final DrawnParcelEntity drawing in snapshot.drawings)
                if (snapshot.holdersAt(drawing, colourLevel)
                    case final Set<String> holders)
                  _polygon(
                    drawing.outline.corners,
                    _colourFor(holders, branches, ParcelInfoColor.unowned),
                    selected: _isSelectedDrawing(drawing),
                    dashed: false,
                    owned: holders.isNotEmpty,
                  ),
            ],
          ),
        if (labels)
          MarkerLayer(
            markers: <Marker>[
              for (final (
                    :LatLng centre,
                    :String label,
                    :Set<String> holders,
                    :Color nobody,
                  )
                  in shown) ...<Marker>[
                _label(centre, label, _colourFor(holders, branches, nobody)),
                if (holders.isNotEmpty)
                  Marker(
                    point: centre,
                    width: ParcelInfoDimens.parcelLabelWidth,
                    height:
                        ParcelInfoDimens.avatar +
                        ParcelInfoDimens.parcelLabelHeight,
                    alignment: Alignment.topCenter,
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: MapOwnerAvatars(
                          holders: _avatars(holders, branches),
                        ),
                      ),
                    ),
                  ),
              ],
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
    required bool owned,
  }) => Polygon(
    points: corners,
    color: color.withValues(
      alpha: owned
          ? ParcelInfoDimens.branchFillAlpha
          : ParcelInfoDimens.unownedFillAlpha,
    ),
    borderColor: selected
        ? ParcelInfoColor.selectedStroke
        : owned
        ? color
        : color.withValues(alpha: ParcelInfoDimens.unownedStrokeAlpha),
    borderStrokeWidth: selected
        ? ParcelInfoDimens.selectedOutline
        : owned
        ? ParcelInfoDimens.outline
        : ParcelInfoDimens.unownedOutline,
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
