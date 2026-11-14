import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/admin_only_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';

/// Removes a person and takes them off every drawing — the main account's
/// call only.
final class DeletePersonUseCase {
  const DeletePersonUseCase(this._auth, this._persons);

  final AuthRepositoryInterface _auth;

  final PersonRepositoryInterface _persons;

  Future<Either<BaseException, String>> call(PersonEntity person) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (!actor.canDelete) {
      return Left(AuthException(cause: AdminOnlyCause()));
    }
    return _persons.delete(person, actor: actor);
  }
}
