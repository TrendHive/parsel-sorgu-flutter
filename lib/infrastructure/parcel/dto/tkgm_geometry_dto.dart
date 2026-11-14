import 'package:json_annotation/json_annotation.dart';
import 'package:parcel_atlas/core/base/base_dto.dart';

part 'tkgm_geometry_dto.g.dart';

/// The `geometry` of a registry answer: a GeoJSON polygon whose
/// [coordinates] are rings of `[longitude, latitude]` pairs, outer ring first.
@JsonSerializable(createToJson: false)
final class TkgmGeometryDTO extends BaseDTO {
  TkgmGeometryDTO({this.type, this.coordinates = const <List<List<num>>>[]});

  factory TkgmGeometryDTO.fromJson(Map<String, dynamic> json) =>
      _$TkgmGeometryDTOFromJson(json);

  final String? type;

  final List<List<List<num>>> coordinates;
}
