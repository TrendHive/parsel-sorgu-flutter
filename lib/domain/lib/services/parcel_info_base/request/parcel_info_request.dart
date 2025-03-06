import 'package:core/base/base_request.dart';
import 'package:domain/services/parcel_info_base/dto/parcel_info_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'parcel_info_request.g.dart';

@JsonSerializable(createFactory: false)
class ParcelInfoRequest extends BaseRequest {
  @JsonKey(name: 'data')
  ParcelInfoDTO data;

  ParcelInfoRequest(this.data);

  @override
  Map<String, dynamic> toJson() => _$ParcelInfoRequestToJson(this);
}
