import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/value_object/credentials_value_object.dart';

/// Who is signed in, and the door in and out.
///
/// [watchMember] emits the member on every change of sign-in state, `null`
/// when nobody is signed in — the router follows it. [currentMember] is the
/// same answer read once, for a use case stamping a change with its author.
/// [signIn] refuses an account the family's list does not hold, even when
/// the password is right.
abstract interface class AuthRepositoryInterface {
  Stream<MemberEntity?> watchMember();

  MemberEntity? get currentMember;

  Future<Either<BaseException, MemberEntity>> signIn(
    CredentialsValueObject credentials,
  );

  Future<void> signOut();
}
