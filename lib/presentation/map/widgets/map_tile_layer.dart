import 'package:flutter_map/flutter_map.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/map/enum/base_map_enum.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';

/// The imagery under the parcels.
///
/// Both sources are free with attribution: Esri World Imagery for aerial
/// photos — the one to draw real boundaries on — and OpenStreetMap for
/// streets and names. Beyond each source's native zoom the last real tile is
/// enlarged, so a corner can still be placed precisely.
class MapTileLayer extends StatelessWidget {
  const MapTileLayer({super.key, required this.baseMap});

  final BaseMapEnum baseMap;

  static const String satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String streetUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const BaseMapEnum defaultBase = BaseMapEnum.satellite;
  static const String userAgentPackage = 'app.parcelatlas';
  static const String satelliteCredit = 'Esri, Maxar, Earthstar Geographics';
  static const String streetCredit = 'OpenStreetMap';

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: switch (baseMap) {
        BaseMapEnum.satellite => satelliteUrl,
        BaseMapEnum.street => streetUrl,
      },
      userAgentPackageName: userAgentPackage,
      maxNativeZoom: switch (baseMap) {
        BaseMapEnum.satellite => MapRules.satelliteNativeZoom,
        BaseMapEnum.street => MapRules.streetNativeZoom,
      },
      maxZoom: MapRules.maxZoom,
    );
  }
}
