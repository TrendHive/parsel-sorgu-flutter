import 'package:flutter_map/flutter_map.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/map/enum/base_map_enum.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_tile_layer.dart';

/// The imagery's credit line, as both free sources require.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key, required this.baseMap});

  final BaseMapEnum baseMap;

  @override
  Widget build(BuildContext context) {
    return SimpleAttributionWidget(
      source: Text(switch (baseMap) {
        BaseMapEnum.satellite => MapTileLayer.satelliteCredit,
        BaseMapEnum.street => MapTileLayer.streetCredit,
      }),
    );
  }
}
