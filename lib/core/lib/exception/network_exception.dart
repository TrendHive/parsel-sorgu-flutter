import 'package:core/base/base_exception.dart';
import 'package:core/exception/code/exception_code.dart';

class NetworkException extends BaseException {
  NetworkException({super.cause})
      : super(
            message: ExceptionCode.network().toString(),
            code: ExceptionCode.network());
}
