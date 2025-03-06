import 'package:application/parcel_get/service/parcel_get_service.dart';
import 'package:core/base/base_request.dart';
import 'package:domain/services/parcel_get/dto/parcel_get_dto_response.dart';
import 'package:domain/services/parcel_get/repository/parcel_get_remote_repository_interface.dart';
import 'package:domain/services/parcel_info_base/response/parcel_info_response.dart';
import 'package:latlong2/latlong.dart';

final class ParcelGetRemoteRepository
    extends ParcelGetRemoteRepositoryInterface {
  final LatLng point;

  ParcelGetRemoteRepository({required this.point});

  @override
  Future<ParcelInfoResponse<ParcelGetDTOResponse>> executer(
    BaseRequest request,
  ) {
    return ParcelGetService(point: point).execute(request);
  }
}
