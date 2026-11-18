import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_parcel_label.dart';

/// The selected parcel's side lengths on the map: one label at the middle
/// of every side, its exact length on the ellipsoid
/// (`GeoRules.edgeLengthsMeters`), bordered in [accent] — the colour of the
/// layer the parcel belongs to.
class MapSideLengthsLayer extends StatelessWidget {
  const MapSideLengthsLayer({
    super.key,
    required this.outline,
    required this.accent,
  });

  final List<LatLng> outline;

  final Color accent;

  static const double _half = 0.5;

  @override
  Widget build(BuildContext context) {
    final ParcelInfoFormat format = ParcelInfoFormat(
      ParcelInfoLocalKeys.of(context),
    );
    final List<double> edges = GeoRules.edgeLengthsMeters(outline);
    return MarkerLayer(
      markers: <Marker>[
        for (int i = CoreConstants.zero; i < edges.length; i++)
          Marker(
            point: _middle(outline[i], outline[(i + 1) % outline.length]),
            width: ParcelInfoDimens.parcelLabelWidth,
            height: ParcelInfoDimens.parcelLabelHeight,
            child: IgnorePointer(
              child: MapParcelLabel(format.length(edges[i]), accent: accent),
            ),
          ),
      ],
    );
  }

  static LatLng _middle(LatLng a, LatLng b) => LatLng(
    (a.latitude + b.latitude) * _half,
    (a.longitude + b.longitude) * _half,
  );
}
