import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'base_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class BaseDTO {
  BaseDTO();
  factory BaseDTO.fromJson(dynamic json) => _$BaseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$BaseDTOToJson(this);
}
