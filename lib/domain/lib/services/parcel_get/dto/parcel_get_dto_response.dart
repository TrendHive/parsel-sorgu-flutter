import 'package:core/base/base_dto.dart';
import 'package:domain/services/geometry/dto/geometry_dto_response.dart';
import 'package:domain/services/properties/dto/properties_dto_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'parcel_get_dto_response.g.dart';

@JsonSerializable(createToJson: false)
final class ParcelGetDTOResponse extends BaseDTO {

  @JsonKey(name: 'type')
  final String type;
  @JsonKey(name: 'geometry')
  final GeometryDTOResponse geometry;
  @JsonKey(name: 'properties')
  final PropertiesDTOResponse properties;

  ParcelGetDTOResponse({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory ParcelGetDTOResponse.fromJson(dynamic json) =>
      _$ParcelGetDTOResponseFromJson(json);
}
