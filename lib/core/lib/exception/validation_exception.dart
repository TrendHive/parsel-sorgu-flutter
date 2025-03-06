import 'package:core/base/base_exception.dart';
import 'package:core/exception/code/exception_code.dart';

class ValidationException extends BaseException {
  ValidationException({super.cause})
      : super(
            message: ExceptionCode.validation().toString(),
            code: ExceptionCode.validation());
}
