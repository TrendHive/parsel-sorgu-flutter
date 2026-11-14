import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';

class InternalServerException extends BaseException {
  InternalServerException({super.cause})
    : super(
        message: ExceptionCode.internalServer().toString(),
        code: ExceptionCode.internalServer(),
      );
}
