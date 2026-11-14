import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/admin_only_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_group_repository_interface.dart';

/// Removes a group and its shares from every drawing — the main account's
/// call only.
final class DeleteGroupUseCase {
  const DeleteGroupUseCase(this._auth, this._groups);

  final AuthRepositoryInterface _auth;

  final PersonGroupRepositoryInterface _groups;

  Future<Either<BaseException, String>> call(PersonGroupEntity group) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (!actor.canDelete) {
      return Left(AuthException(cause: AdminOnlyCause()));
    }
    return _groups.delete(group, actor: actor);
  }
}
