import 'package:application/parcel_get/mapper/parcel_get_mapper.dart';
import 'package:application/parcel_get/repository/parcel_get_remote_repository.dart';
import 'package:core/base/base_exception.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';
import 'package:domain/services/parcel_get/dto/parcel_get_dto_response.dart';
import 'package:domain/services/parcel_get/usecase/parcel_get_usecase_interface.dart';
import 'package:domain/services/parcel_info_base/request/parcel_info_request.dart';
import 'package:domain/services/parcel_info_base/response/parcel_info_response.dart';
import 'package:either_dart/either.dart';

final class ParcelGetUseCase implements ParcelGetUseCaseInterface {
  @override
  ParcelGetMapper get mapper => ParcelGetMapper();

  @override
  Future<Either<BaseException, ParcelInfoModel>> execute(
      ParcelInfoModel input) async {
    ParcelGetRemoteRepository privacyPolicyRemoteRepository =
        ParcelGetRemoteRepository(point: input.point);

    ParcelInfoRequest parcelInfoRequest =
        ParcelInfoRequest(mapper.createFromModel(input));

    Either<BaseException, ParcelInfoResponse<ParcelGetDTOResponse>> result =
        await privacyPolicyRemoteRepository.execute(parcelInfoRequest);

    return result.fold(
        (left) => Left(left), (right) => mapper.updateModel(input, right.data));
  }
}
