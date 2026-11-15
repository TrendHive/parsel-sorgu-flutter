import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/family_loop_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';

/// Adds a person when `existing` is null, or changes one — their name,
/// their parent in the family tree, whether their shares have passed to
/// their children, or their note.
///
/// `family` is everyone already stored; a parent link that would make the
/// person their own ancestor is refused.
final class SavePersonUseCase {
  const SavePersonUseCase(this._auth, this._persons);

  final AuthRepositoryInterface _auth;

  final PersonRepositoryInterface _persons;

  Future<Either<BaseException, String>> call({
    required String name,
    required String? parentId,
    required bool passesToChildren,
    required String note,
    required List<PersonEntity> family,
    PersonEntity? existing,
  }) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (existing != null &&
        parentId != null &&
        !FamilyRules.canBeParent(
          family,
          childId: existing.id,
          parentId: parentId,
        )) {
      return Left(ValidationException(cause: FamilyLoopCause()));
    }
    final Either<BaseException, PersonEntity> person = existing == null
        ? PersonEntity.create(
            name: name,
            parentId: parentId,
            passesToChildren: passesToChildren,
            note: note,
          )
        : existing.edit(
            name: name,
            parentId: parentId,
            passesToChildren: passesToChildren,
            note: note,
          );
    return switch (person) {
      Left(:final BaseException value) => Left(value),
      Right(:final PersonEntity value) => _persons.save(value, actor: actor),
    };
  }
}
