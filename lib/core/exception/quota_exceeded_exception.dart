import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';

/// An external service refused because its daily allowance is spent.
///
/// Its own kind because the answer differs from every other failure:
/// retrying makes it worse, and everything already stored keeps working.
class QuotaExceededException extends BaseException {
  QuotaExceededException({super.cause})
    : super(
        message: ExceptionCode.quotaExceeded().toString(),
        code: ExceptionCode.quotaExceeded(),
      );
}
