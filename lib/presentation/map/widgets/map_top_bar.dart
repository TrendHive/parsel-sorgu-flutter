import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/map/enum/base_map_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// The bar over the map while browsing.
///
/// The two layer switches are the first thing on it — comparing the
/// registry's boundaries with the real ones is the app's main question.
/// Then the imagery switch, and the actions: a search by parcel number, the
/// colouring by a level of the family tree ([colourLabels] names each level,
/// [colourLevel] is the one in use), a new freehand drawing, the device's
/// location, people, history and sign out.
///
/// In a [compact] window people, history and sign out fold into one menu,
/// so the bar stays two rows high on a phone and the map stays visible.
class MapTopBar extends StatelessWidget {
  const MapTopBar({
    super.key,
    required this.compact,
    required this.layers,
    required this.baseMap,
    required this.onToggleLayer,
    required this.onBaseMap,
    required this.colourLevel,
    required this.colourLabels,
    required this.onColour,
    required this.onSearch,
    required this.onNewDrawing,
    required this.onMyLocation,
    required this.onPeople,
    required this.onActivity,
    required this.onSignOut,
  });

  final bool compact;

  final Set<MapLayerEnum> layers;

  final BaseMapEnum baseMap;

  final ValueChanged<MapLayerEnum> onToggleLayer;

  final ValueChanged<BaseMapEnum> onBaseMap;

  final int? colourLevel;

  final List<String> colourLabels;

  final ValueChanged<int?> onColour;

  final VoidCallback onSearch;

  final VoidCallback onNewDrawing;

  static const int _colourOff = -1;

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
              tooltip: l10n.searchParcel,
              icon: const Icon(Icons.search),
              onPressed: onSearch,
            ),
            PopupMenuButton<int>(
              tooltip: l10n.colourBy,
              icon: Icon(
                colourLevel == null ? Icons.palette_outlined : Icons.palette,
              ),
              onSelected: (int level) =>
                  onColour(level == _colourOff ? null : level),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                CheckedPopupMenuItem<int>(
                  value: _colourOff,
                  checked: colourLevel == null,
                  child: ParcelInfoText(l10n.colourOff),
                ),
                for (final (int level, String label) in colourLabels.indexed)
                  CheckedPopupMenuItem<int>(
                    value: level,
                    checked: colourLevel == level,
                    child: ParcelInfoText(label),
                  ),
              ],
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
            if (compact)
              PopupMenuButton<VoidCallback>(
                tooltip: l10n.menuPeople,
                icon: const Icon(Icons.more_vert),
                onSelected: (VoidCallback action) => action(),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<VoidCallback>>[
                      PopupMenuItem<VoidCallback>(
                        value: onPeople,
                        child: ListTile(
                          leading: const Icon(Icons.account_tree_outlined),
                          title: ParcelInfoText(l10n.menuPeople),
                        ),
                      ),
                      PopupMenuItem<VoidCallback>(
                        value: onActivity,
                        child: ListTile(
                          leading: const Icon(Icons.history),
                          title: ParcelInfoText(l10n.menuActivity),
                        ),
                      ),
                      PopupMenuItem<VoidCallback>(
                        value: onSignOut,
                        child: ListTile(
                          leading: const Icon(Icons.logout),
                          title: ParcelInfoText(l10n.signOut),
                        ),
                      ),
                    ],
              )
            else ...<Widget>[
              IconButton.filledTonal(
                tooltip: l10n.menuPeople,
                icon: const Icon(Icons.account_tree_outlined),
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
          ],
        ),
      ),
    );
  }
}
