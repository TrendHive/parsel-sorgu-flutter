import 'package:domain/parcel_info/model/parcel_info_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class HomeBody extends StatelessWidget {
  final String packageName;
  final String urlTemplate;
  final TapCallback onTap;
  final ParcelInfoListModel parcelInfoListModel;

  const HomeBody({
    super.key,
    required this.packageName,
    required this.urlTemplate,
    required this.onTap,
    required this.parcelInfoListModel,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        onTap: onTap,
        initialCenter: parcelInfoListModel.location,
      ),
      children: [
        TileLayer(
          urlTemplate: urlTemplate,
          userAgentPackageName: packageName,
        ),
        PolygonLayer(
          polygons: parcelInfoListModel.parcelInfoList
              .map((e) => Polygon(
                    points: e.polygonCoordinates,
                    color: Colors.blue
                        .withValues(alpha: 0.3), // İç dolgu rengi (transparent)
                    borderColor: Colors.blue, // Kenar çizgi rengi
                    borderStrokeWidth: 2.0,
                    label: "Polygon",
                  ))
              .toList(),
        ),
        const RichAttributionWidget(attributions: []),
      ],
    );
  }
}
