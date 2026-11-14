import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/auth/value_object/credentials_value_object.dart';

/// Lets a family member in with the username and password they were given.
///
/// Blank fields are answered on the device, before a round trip.
final class SignInUseCase {
  const SignInUseCase(this._auth);

  final AuthRepositoryInterface _auth;

  Future<Either<BaseException, MemberEntity>> call({
    required String username,
    required String password,
  }) async {
    final CredentialsValueObject credentials = CredentialsValueObject(
      username: username,
      password: password,
    );
    return switch (credentials.valueObject) {
      Left(:final BaseException value) => Left(value),
      Right() => await _auth.signIn(credentials),
    };
  }
}
