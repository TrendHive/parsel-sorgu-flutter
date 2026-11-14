import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/validator/min_corners_validator.dart';

/// A parcel's outline: WGS84 corners, in order, without the closing repeat.
///
/// Every measurement is a getter over [GeoRules], so the same polygon always
/// reports the same area wherever it is shown or stored. [empty] is the
/// outline of nothing — const, for drafts that have not started.
///
/// [areaSquareMeters], [perimeterMeters] and [edgeLengthsMeters] are the
/// ellipsoidal measurements; [centre] is where a label sits; [contains] is the
/// inside test that answers a tap from what is stored.
final class GeoPolygonValueObject extends BaseValueObject<List<LatLng>> {
  const GeoPolygonValueObject(super.value);

  static const GeoPolygonValueObject empty = GeoPolygonValueObject(<LatLng>[]);

  @override
  List<BaseValueValidator<List<LatLng>>> get validators =>
      const <BaseValueValidator<List<LatLng>>>[MinCornersValidator()];

  List<LatLng> get corners => value;

  double get areaSquareMeters => GeoRules.areaSquareMeters(value);

  double get perimeterMeters => GeoRules.perimeterMeters(value);

  List<double> get edgeLengthsMeters => GeoRules.edgeLengthsMeters(value);

  LatLng get centre => GeoRules.centre(value);

  bool contains(LatLng point) =>
      value.isNotEmpty && GeoRules.contains(value, point);
}
