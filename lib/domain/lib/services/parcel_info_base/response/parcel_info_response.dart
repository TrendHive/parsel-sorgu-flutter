import 'package:core/base/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'parcel_info_response.g.dart';

@JsonSerializable(
  genericArgumentFactories: true,
  createToJson: false,
)
class ParcelInfoResponse<ResponseDTO> extends BaseResponse {
  @JsonKey(name: 'data')
  ResponseDTO data;

  ParcelInfoResponse({
    required this.data,
  });

  factory ParcelInfoResponse.fromJson(
    Map<String, dynamic> json,
    ResponseDTO Function(dynamic json) fromJsonResponseDTO,
  ) =>
      _$ParcelInfoResponseFromJson(json, fromJsonResponseDTO);
}
