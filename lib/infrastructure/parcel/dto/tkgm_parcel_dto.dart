import 'package:json_annotation/json_annotation.dart';
import 'package:parcel_atlas/core/base/base_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_geometry_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_properties_dto.dart';

part 'tkgm_parcel_dto.g.dart';

/// One registry answer: a GeoJSON feature with the parcel's outline and its
/// properties. See `docs/tkgm-api.md`.
@JsonSerializable(createToJson: false)
final class TkgmParcelDTO extends BaseDTO {
  TkgmParcelDTO({this.geometry, this.properties});

  factory TkgmParcelDTO.fromJson(Map<String, dynamic> json) =>
      _$TkgmParcelDTOFromJson(json);

  final TkgmGeometryDTO? geometry;

  final TkgmPropertiesDTO? properties;
}
