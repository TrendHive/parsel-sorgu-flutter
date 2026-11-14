import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/parcel/rule/parcel_rules.dart';

/// Everything the official registry says about one parcel, as it said it.
///
/// The named fields are the ones the app reads; [attributes] keeps every
/// property of the answer verbatim, so nothing the registry sent is lost even
/// if a later screen wants a field nobody reads today.
///
/// [registryAreaSquareMeters] is the registry's own area figure — the
/// authoritative one. The [outline] it sends is rounded to five decimals
/// (about a metre), so an area computed from it differs by a few percent;
/// the app shows the registry's figure for an official parcel and computes
/// only what the family drew.
///
/// [key] and [label] come from `ParcelRules`.
final class RegistryRecordValueObject
    extends BaseValueObject<RegistryRecordFields> {
  const RegistryRecordValueObject(super.value);

  @override
  List<BaseValueValidator<RegistryRecordFields>> get validators =>
      const <BaseValueValidator<RegistryRecordFields>>[];

  String get key => ParcelRules.keyOf(
    neighborhoodId: value.neighborhoodId,
    block: value.block,
    parcel: value.parcel,
  );

  String get label =>
      ParcelRules.labelOf(block: value.block, parcel: value.parcel);

  bool get isActive => value.status == ParcelRules.activeStatus;

  int get neighborhoodId => value.neighborhoodId;

  String get block => value.block;

  String get parcel => value.parcel;

  String get cityName => value.cityName;

  String get districtName => value.districtName;

  String get neighborhoodName => value.neighborhoodName;

  String get locality => value.locality;

  String get quality => value.quality;

  String get sheet => value.sheet;

  String get landStatus => value.landStatus;

  double? get registryAreaSquareMeters => value.registryAreaSquareMeters;

  GeoPolygonValueObject get outline => value.outline;

  Map<String, String> get attributes => value.attributes;
}

/// The fields of a [RegistryRecordValueObject], named.
typedef RegistryRecordFields = ({
  int neighborhoodId,
  String block,
  String parcel,
  String cityName,
  String districtName,
  String neighborhoodName,
  String locality,
  String quality,
  String sheet,
  String landStatus,
  String status,
  double? registryAreaSquareMeters,
  GeoPolygonValueObject outline,
  Map<String, String> attributes,
});
