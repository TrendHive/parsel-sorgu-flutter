import 'package:core/base/base_exception.dart';
import 'package:core/exception/code/exception_code.dart';

class UnknownException extends BaseException {
  UnknownException({super.cause})
      : super(
            message: ExceptionCode.unknown().toString(),
            code: ExceptionCode.unknown());
}
