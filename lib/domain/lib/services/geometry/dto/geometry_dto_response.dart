import 'package:core/base/base_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geometry_dto_response.g.dart';

@JsonSerializable(createToJson: false)
final class GeometryDTOResponse extends BaseDTO {
  @JsonKey(name: 'type')
  final String type;
  @JsonKey(name: 'coordinates')
  final List<List<List<double>>> coordinates;

  GeometryDTOResponse({
    required this.type,
    required this.coordinates,
  });

  factory GeometryDTOResponse.fromJson(dynamic json) =>
      _$GeometryDTOResponseFromJson(json);
}
