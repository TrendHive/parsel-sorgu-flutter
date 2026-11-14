import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';

/// The family's groups of people.
///
/// [save] creates a group whose id is empty and updates one that has an id,
/// answering the id. [delete] removes the group AND its shares from every
/// drawing in the same atomic batch.
abstract interface class PersonGroupRepositoryInterface {
  Stream<Either<BaseException, List<PersonGroupEntity>>> watchAll();

  Future<Either<BaseException, String>> save(
    PersonGroupEntity group, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> delete(
    PersonGroupEntity group, {
    required MemberEntity actor,
  });
}
