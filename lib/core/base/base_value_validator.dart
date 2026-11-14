import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';

/// One check a value must pass.
///
/// [validate] answers `Right(value)` when the value passes and `Left` with the
/// exception (and its cause) when it does not. A validator checks ONE thing,
/// so a value object's rules read as a list and the first one broken is the
/// one the user is told about.
abstract class BaseValueValidator<T> {
  const BaseValueValidator();

  Either<BaseException, T> validate(T value);
}
