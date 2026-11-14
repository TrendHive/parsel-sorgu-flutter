import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';

/// Adds a person when `existing` is null, or renames one.
final class SavePersonUseCase {
  const SavePersonUseCase(this._auth, this._persons);

  final AuthRepositoryInterface _auth;

  final PersonRepositoryInterface _persons;

  Future<Either<BaseException, String>> call({
    required String name,
    required String note,
    PersonEntity? existing,
  }) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    final Either<BaseException, PersonEntity> person = existing == null
        ? PersonEntity.create(name: name, note: note)
        : existing.rename(name: name, note: note);
    return switch (person) {
      Left(:final BaseException value) => Left(value),
      Right(:final PersonEntity value) => _persons.save(value, actor: actor),
    };
  }
}
