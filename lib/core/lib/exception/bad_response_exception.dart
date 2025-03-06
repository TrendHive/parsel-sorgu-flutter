import 'package:core/base/base_exception.dart';
import 'package:core/exception/code/exception_code.dart';

class BadResponseException extends BaseException {
  BadResponseException({super.cause})
      : super(
            message: ExceptionCode.badResponse().toString(),
            code: ExceptionCode.badResponse());
}
