import 'package:core/base/base_exception.dart';
import 'package:core/base/base_usecase.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';

abstract interface class ParcelGetUseCaseInterface
    extends BaseUseCase<ParcelInfoModel, BaseException> {}
