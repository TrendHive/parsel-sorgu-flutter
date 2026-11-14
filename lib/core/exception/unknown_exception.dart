import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';

class UnknownException extends BaseException {
  UnknownException({super.cause})
    : super(
        message: ExceptionCode.unknown().toString(),
        code: ExceptionCode.unknown(),
      );
}
