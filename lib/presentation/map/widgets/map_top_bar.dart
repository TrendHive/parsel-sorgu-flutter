import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain/map/enum/base_map_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// The bar over the map while browsing.
///
/// The two layer switches are the first thing on it — comparing the
/// registry's boundaries with the real ones is the app's main question.
/// Then the imagery switch, and the actions: a new freehand drawing, the
/// device's location, people, history and sign out.
class MapTopBar extends StatelessWidget {
  const MapTopBar({
    super.key,
    required this.layers,
    required this.baseMap,
    required this.onToggleLayer,
    required this.onBaseMap,
    required this.onNewDrawing,
    required this.onMyLocation,
    required this.onPeople,
    required this.onActivity,
    required this.onSignOut,
  });

  final Set<MapLayerEnum> layers;

  final BaseMapEnum baseMap;

  final ValueChanged<MapLayerEnum> onToggleLayer;

  final ValueChanged<BaseMapEnum> onBaseMap;

  final VoidCallback onNewDrawing;

  final VoidCallback onMyLocation;

  final VoidCallback onPeople;

  final VoidCallback onActivity;

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.medium),
        child: Wrap(
          spacing: BaseDimens.margin.medium,
          runSpacing: BaseDimens.margin.medium,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilterChip(
              avatar: const Icon(Icons.gavel_outlined),
              label: ParcelInfoText(l10n.layerOfficial),
              selected: layers.contains(MapLayerEnum.official),
              onSelected: (_) => onToggleLayer(MapLayerEnum.official),
            ),
            FilterChip(
              avatar: const Icon(Icons.edit_location_alt_outlined),
              label: ParcelInfoText(l10n.layerDrawn),
              selected: layers.contains(MapLayerEnum.drawn),
              onSelected: (_) => onToggleLayer(MapLayerEnum.drawn),
            ),
            SegmentedButton<BaseMapEnum>(
              showSelectedIcon: false,
              segments: <ButtonSegment<BaseMapEnum>>[
                ButtonSegment<BaseMapEnum>(
                  value: BaseMapEnum.satellite,
                  icon: const Icon(Icons.satellite_alt_outlined),
                  label: ParcelInfoText(l10n.baseSatellite),
                ),
                ButtonSegment<BaseMapEnum>(
                  value: BaseMapEnum.street,
                  icon: const Icon(Icons.map_outlined),
                  label: ParcelInfoText(l10n.baseStreet),
                ),
              ],
              selected: <BaseMapEnum>{baseMap},
              onSelectionChanged: (Set<BaseMapEnum> value) =>
                  onBaseMap(value.first),
            ),
            IconButton.filledTonal(
              tooltip: l10n.newDrawing,
              icon: const Icon(Icons.draw_outlined),
              onPressed: onNewDrawing,
            ),
            IconButton.filledTonal(
              tooltip: l10n.myLocation,
              icon: const Icon(Icons.my_location),
              onPressed: onMyLocation,
            ),
            IconButton.filledTonal(
              tooltip: l10n.menuPeople,
              icon: const Icon(Icons.groups_outlined),
              onPressed: onPeople,
            ),
            IconButton.filledTonal(
              tooltip: l10n.menuActivity,
              icon: const Icon(Icons.history),
              onPressed: onActivity,
            ),
            IconButton(
              tooltip: l10n.signOut,
              icon: const Icon(Icons.logout),
              onPressed: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}
