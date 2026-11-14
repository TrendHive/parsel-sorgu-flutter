import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/no_parcel_cause.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/exception/not_found_exception.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_parcel_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_properties_dto.dart';

/// Turns a registry answer into a [RegistryRecordValueObject].
///
/// The parcel's identity — neighbourhood, block, parcel number — and an
/// outline with at least three corners are required; an answer without them
/// is "no parcel here". Everything else is optional and defaults to empty.
///
/// [registryArea] reads the registry's Turkish-formatted area: `.` groups
/// thousands and `,` is the decimal mark, so `"98.199,20"` is 98199.2.
/// Coordinates arrive as `[longitude, latitude]` and the closing corner that
/// repeats the first is dropped.
class TkgmParcelMapper {
  const TkgmParcelMapper();

  Either<BaseException, RegistryRecordValueObject> toRecord(TkgmParcelDTO dto) {
    final TkgmPropertiesDTO? p = dto.properties;
    final int? neighborhoodId = p?.mahalleId;
    final String block = p?.adaNo?.trim() ?? CoreConstants.empty;
    final String parcel = p?.parselNo?.trim() ?? CoreConstants.empty;
    final GeoPolygonValueObject outline = GeoPolygonValueObject(
      _outerRing(dto),
    );
    if (p == null ||
        neighborhoodId == null ||
        block.isEmpty ||
        parcel.isEmpty ||
        !outline.isValid) {
      return Left(NotFoundException(cause: NoParcelCause()));
    }
    return Right(
      RegistryRecordValueObject((
        neighborhoodId: neighborhoodId,
        block: block,
        parcel: parcel,
        cityName: p.ilAd ?? CoreConstants.empty,
        districtName: p.ilceAd ?? CoreConstants.empty,
        neighborhoodName: p.mahalleAd ?? CoreConstants.empty,
        locality: p.mevkii ?? CoreConstants.empty,
        quality: p.nitelik ?? CoreConstants.empty,
        sheet: p.pafta ?? CoreConstants.empty,
        landStatus: p.zeminKmdurum ?? CoreConstants.empty,
        status: p.durum ?? CoreConstants.empty,
        registryAreaSquareMeters: registryArea(p.alan),
        outline: outline,
        attributes: Map<String, String>.unmodifiable(p.raw),
      )),
    );
  }

  static double? registryArea(String? text) => text == null
      ? null
      : double.tryParse(
          text
              .replaceAll(CoreConstants.dot, CoreConstants.empty)
              .replaceAll(CoreConstants.comma, CoreConstants.dot),
        );

  List<LatLng> _outerRing(TkgmParcelDTO dto) {
    final List<List<List<num>>> rings =
        dto.geometry?.coordinates ?? const <List<List<num>>>[];
    if (rings.isEmpty) return const <LatLng>[];
    final List<LatLng> ring = <LatLng>[
      for (final List<num> pair in rings.first)
        if (pair.length >= CoreConstants.two)
          LatLng(pair[CoreConstants.one].toDouble(), pair.first.toDouble()),
    ];
    return ring.length > CoreConstants.one && ring.first == ring.last
        ? ring.sublist(CoreConstants.zero, ring.length - CoreConstants.one)
        : ring;
  }
}
