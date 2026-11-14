import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';

class ValidationException extends BaseException {
  ValidationException({super.cause})
    : super(
        message: ExceptionCode.validation().toString(),
        code: ExceptionCode.validation(),
      );
}
