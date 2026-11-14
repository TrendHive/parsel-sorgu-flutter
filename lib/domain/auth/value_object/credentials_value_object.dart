import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';
import 'package:parcel_atlas/core/validator/not_blank_validator.dart';
import 'package:parcel_atlas/domain/input/enum/input_field_enum.dart';

/// A username and a password, checked before anything is sent.
///
/// The username is trimmed and lower-cased, because a member typing "Recep"
/// on one phone and "recep" on another is the same person.
final class CredentialsValueObject
    extends BaseValueObject<({String username, String password})> {
  CredentialsValueObject({required String username, required String password})
    : super((username: username.trim().toLowerCase(), password: password));

  @override
  List<BaseValueValidator<({String username, String password})>>
  get validators =>
      const <BaseValueValidator<({String username, String password})>>[];

  @override
  Either<BaseException, ({String username, String password})> get valueObject {
    final Either<BaseException, String> username = NotBlankValidator(
      InputFieldEnum.username.name,
    ).validate(value.username);
    if (username.isLeft) return Left(username.left);
    final Either<BaseException, String> password = NotBlankValidator(
      InputFieldEnum.password.name,
    ).validate(value.password);
    if (password.isLeft) return Left(password.left);
    return Right(value);
  }

  String get username => value.username;

  String get password => value.password;
}
