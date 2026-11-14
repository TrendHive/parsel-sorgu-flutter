import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/cause/shares_exceed_whole_cause.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';

/// Passes a share between nothing and the whole parcel: a positive
/// numerator no larger than a positive denominator.
final class ProperFractionValidator
    extends BaseValueValidator<({int numerator, int denominator})> {
  const ProperFractionValidator();

  @override
  Either<BaseException, ({int numerator, int denominator})> validate(
    ({int numerator, int denominator}) value,
  ) =>
      value.numerator > CoreConstants.zero &&
          value.denominator > CoreConstants.zero &&
          value.numerator <= value.denominator
      ? Right(value)
      : Left(ValidationException(cause: SharesExceedWholeCause()));
}
