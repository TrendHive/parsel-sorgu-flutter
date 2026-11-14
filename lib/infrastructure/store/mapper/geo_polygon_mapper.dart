import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';

/// Writes and reads an outline.
///
/// Firestore has no nested arrays, so each corner is a `{lat, lng}` map in
/// one list — at full double precision, so a drawn corner keeps every digit
/// the map gave it.
class GeoPolygonMapper {
  const GeoPolygonMapper();

  static const String lat = 'lat';
  static const String lng = 'lng';

  List<Map<String, double>> write(GeoPolygonValueObject outline) =>
      <Map<String, double>>[
        for (final LatLng corner in outline.corners)
          <String, double>{lat: corner.latitude, lng: corner.longitude},
      ];

  GeoPolygonValueObject read(Object? raw) => GeoPolygonValueObject(<LatLng>[
    if (raw is List)
      for (final Object? corner in raw)
        if (corner is Map<String, dynamic> &&
            corner[lat] is num &&
            corner[lng] is num)
          LatLng(
            (corner[lat] as num).toDouble(),
            (corner[lng] as num).toDouble(),
          ),
  ]);
}
