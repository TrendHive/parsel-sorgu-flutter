import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';

/// The thing asked for does not exist — no parcel under a point, a record
/// another device deleted meanwhile.
class NotFoundException extends BaseException {
  NotFoundException({super.cause})
    : super(
        message: ExceptionCode.notFound().toString(),
        code: ExceptionCode.notFound(),
      );
}
