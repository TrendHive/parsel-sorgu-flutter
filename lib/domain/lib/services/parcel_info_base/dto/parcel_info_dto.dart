import 'package:core/base/base_dto.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'parcel_info_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ParcelInfoDTO extends BaseDTO {
  ParcelInfoDTO();
  factory ParcelInfoDTO.fromJson(Map<String, dynamic> json) =>
      _$ParcelInfoDTOFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParcelInfoDTOToJson(this);
}
