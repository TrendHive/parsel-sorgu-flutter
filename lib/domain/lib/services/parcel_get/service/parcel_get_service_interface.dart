import 'package:core/base/base_request.dart';
import 'package:core/base/base_service.dart';
import 'package:domain/services/parcel_get/dto/parcel_get_dto_response.dart';
import 'package:domain/services/parcel_info_base/response/parcel_info_response.dart';

abstract class ParcelGetServiceInterface extends BaseService {
  @override
  Future<ParcelInfoResponse<ParcelGetDTOResponse>> execute(
    BaseRequest request,
  );
}
