import 'package:core/base/base_request.dart';
import 'package:domain/services/parcel_get/dto/parcel_get_dto_response.dart';
import 'package:domain/services/parcel_get/service/parcel_get_service_interface.dart';
import 'package:domain/services/parcel_info_base/response/parcel_info_response.dart';
import 'package:infrastructure/network/dio_client.dart';
import 'package:latlong2/latlong.dart';

final class ParcelGetService implements ParcelGetServiceInterface {
  final LatLng point;

  ParcelGetService({required this.point});

  @override
  String get endpoint => '/parsel/${point.latitude}/${point.longitude}';

  @override
  Future<ParcelInfoResponse<ParcelGetDTOResponse>> execute(
    BaseRequest request,
  ) async {
    var response = await DioClient().dio.get(endpoint);

    var data = response.data;

    return ParcelInfoResponse.fromJson(data, ParcelGetDTOResponse.fromJson);
  }
}
