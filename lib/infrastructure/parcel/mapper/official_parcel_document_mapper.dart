import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/geo_polygon_mapper.dart';

/// A registry parcel as a store document, and back.
///
/// [writeRecord] is the registry's answer only — no stamps — so a refresh can
/// merge it over the stored document and keep the first lookup's `created`.
/// [read] answers null for a document without a parcel number, which the
/// store service then skips.
class OfficialParcelDocumentMapper {
  const OfficialParcelDocumentMapper();

  static const String neighborhoodId = 'neighborhoodId';
  static const String block = 'block';
  static const String parcel = 'parcel';
  static const String cityName = 'cityName';
  static const String districtName = 'districtName';
  static const String neighborhoodName = 'neighborhoodName';
  static const String locality = 'locality';
  static const String quality = 'quality';
  static const String sheet = 'sheet';
  static const String landStatus = 'landStatus';
  static const String status = 'status';
  static const String registryArea = 'registryAreaSquareMeters';
  static const String outline = 'outline';
  static const String attributes = 'attributes';
  static const String created = 'created';
  static const String refreshed = 'refreshed';

  static const GeoPolygonMapper _outline = GeoPolygonMapper();
  static const AuditStampMapper _stamps = AuditStampMapper();

  Map<String, Object?> writeRecord(RegistryRecordValueObject record) =>
      <String, Object?>{
        neighborhoodId: record.neighborhoodId,
        block: record.block,
        parcel: record.parcel,
        cityName: record.cityName,
        districtName: record.districtName,
        neighborhoodName: record.neighborhoodName,
        locality: record.locality,
        quality: record.quality,
        sheet: record.sheet,
        landStatus: record.landStatus,
        status: record.value.status,
        registryArea: record.registryAreaSquareMeters,
        outline: _outline.write(record.outline),
        attributes: record.attributes,
      };

  OfficialParcelEntity? read(String id, Map<String, dynamic> data) {
    final Object? number = data[neighborhoodId];
    if (number is! num || data[block] == null || data[parcel] == null) {
      return null;
    }
    String text(String key) => '${data[key] ?? CoreConstants.empty}';
    final Object? area = data[registryArea];
    final Object? raw = data[attributes];
    return OfficialParcelEntity(
      record: RegistryRecordValueObject((
        neighborhoodId: number.toInt(),
        block: text(block),
        parcel: text(parcel),
        cityName: text(cityName),
        districtName: text(districtName),
        neighborhoodName: text(neighborhoodName),
        locality: text(locality),
        quality: text(quality),
        sheet: text(sheet),
        landStatus: text(landStatus),
        status: text(status),
        registryAreaSquareMeters: area is num ? area.toDouble() : null,
        outline: _outline.read(data[outline]),
        attributes: <String, String>{
          if (raw is Map<String, dynamic>)
            for (final MapEntry<String, dynamic> e in raw.entries)
              e.key: '${e.value ?? CoreConstants.empty}',
        },
      )),
      created: _stamps.read(data[created]),
      refreshed: _stamps.read(data[refreshed]),
    );
  }
}
