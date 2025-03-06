import 'package:core/base/base_exception.dart';
import 'package:core/exception/code/exception_code.dart';

class InternalServerException extends BaseException {
  InternalServerException({super.cause})
      : super(
            message: ExceptionCode.internalServer().toString(),
            code: ExceptionCode.internalServer());
}
