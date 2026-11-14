import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_group_repository_interface.dart';

/// Creates a group when `existing` is null, or changes one — its name, its
/// members or its note. Every parcel the group holds follows the change.
final class SaveGroupUseCase {
  const SaveGroupUseCase(this._auth, this._groups);

  final AuthRepositoryInterface _auth;

  final PersonGroupRepositoryInterface _groups;

  Future<Either<BaseException, String>> call({
    required String name,
    required List<String> memberIds,
    required String note,
    PersonGroupEntity? existing,
  }) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    final Either<BaseException, PersonGroupEntity> group = existing == null
        ? PersonGroupEntity.create(name: name, memberIds: memberIds, note: note)
        : existing.edit(name: name, memberIds: memberIds, note: note);
    return switch (group) {
      Left(:final BaseException value) => Left(value),
      Right(:final PersonGroupEntity value) => _groups.save(
        value,
        actor: actor,
      ),
    };
  }
}
