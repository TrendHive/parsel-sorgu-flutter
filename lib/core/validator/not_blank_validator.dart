import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/cause/empty_value_cause.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';

/// Passes a string with something in it besides whitespace.
///
/// [field] names the input in the [EmptyCause], so the screen can say which
/// field is missing.
final class NotBlankValidator extends BaseValueValidator<String> {
  const NotBlankValidator(this.field);

  final String field;

  @override
  Either<BaseException, String> validate(String value) => value.trim().isEmpty
      ? Left(ValidationException(cause: EmptyCause(cause: field)))
      : Right(value);
}
