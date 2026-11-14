import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/cause/shares_exceed_whole_cause.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// Passes a parcel's ownership lines when each share is a proper fraction
/// and together they do not exceed the whole parcel.
final class SharesWithinWholeValidator
    extends BaseValueValidator<List<OwnershipValueObject>> {
  const SharesWithinWholeValidator();

  @override
  Either<BaseException, List<OwnershipValueObject>> validate(
    List<OwnershipValueObject> value,
  ) {
    ShareValueObject total = ShareValueObject.none;
    for (final OwnershipValueObject line in value) {
      if (!line.share.isValid) {
        return Left(ValidationException(cause: SharesExceedWholeCause()));
      }
      total = total.plus(line.share);
    }
    return total.compareTo(ShareValueObject.whole) > 0
        ? Left(ValidationException(cause: SharesExceedWholeCause()))
        : Right(value);
  }
}
