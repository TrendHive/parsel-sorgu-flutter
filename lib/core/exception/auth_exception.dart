import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';

class AuthException extends BaseException {
  AuthException({super.cause})
    : super(
        message: ExceptionCode.auth().toString(),
        code: ExceptionCode.auth(),
      );
}
