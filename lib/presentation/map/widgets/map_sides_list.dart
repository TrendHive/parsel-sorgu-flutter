import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_info_row.dart';

/// A parcel's sides, opened on demand: each side from corner to corner
/// ("1–2", …, the last back to 1) with its exact length on the ellipsoid,
/// then the perimeter. The same numbers stand on the map beside each side.
class MapSidesList extends StatelessWidget {
  const MapSidesList({super.key, required this.outline});

  final List<LatLng> outline;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final List<double> edges = GeoRules.edgeLengthsMeters(outline);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: ParcelInfoText(l10n.edgesLabel),
      children: <Widget>[
        for (int i = CoreConstants.zero; i < edges.length; i++)
          MapInfoRow(
            label:
                '${i + CoreConstants.one}–${(i + CoreConstants.one) % edges.length + CoreConstants.one}',
            value: format.length(edges[i]),
          ),
        MapInfoRow(
          label: l10n.perimeterLabel,
          value: format.length(GeoRules.perimeterMeters(outline)),
        ),
      ],
    );
  }
}
