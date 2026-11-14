import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';

/// A value with no identity, equal to another with the same [value].
///
/// The object wraps [value] and lists the [validators] it must pass;
/// [valueObject] is the first broken rule as a [BaseException] or the value,
/// and [isValid] says which. The check runs when asked rather than in the
/// constructor, so a value object can still be `const`.
///
/// Equality is by [value]: two polygons with the same corners are the same
/// polygon, which is the definition of a value object and what lets a Cubit
/// tell "nothing changed" from "something did".
abstract class BaseValueObject<T> extends Equatable {
  const BaseValueObject(this.value);

  final T value;

  List<BaseValueValidator<T>> get validators;

  Either<BaseException, T> get valueObject {
    for (final BaseValueValidator<T> validator in validators) {
      final Either<BaseException, T> result = validator.validate(value);
      if (result.isLeft) return result;
    }
    return Right(value);
  }

  bool get isValid => valueObject.isRight;

  @override
  List<Object?> get props => <Object?>[value];
}
