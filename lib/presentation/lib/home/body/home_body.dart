import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeBody extends StatelessWidget {
  final String packageName;
  final String urlTemplate;
  final TapCallback onTap;
  final LatLng initialCenter;

  const HomeBody({
    super.key,
    required this.packageName,
    required this.urlTemplate,
    required this.onTap,
    required this.initialCenter,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        onTap: onTap,
        initialCenter: initialCenter,
      ),
      children: [
        TileLayer(
          urlTemplate: urlTemplate,
          userAgentPackageName: packageName,
        ),
        const RichAttributionWidget(attributions: []),
      ],
    );
  }
}
