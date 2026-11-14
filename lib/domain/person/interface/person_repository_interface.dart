import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';

/// The family's people.
///
/// [save] creates a person whose id is empty and updates one that has an id,
/// answering the id. [delete] removes the person AND takes them off every
/// drawing's shares and every group in the same atomic batch, so nothing is
/// ever left pointing at someone who no longer exists.
abstract interface class PersonRepositoryInterface {
  Stream<Either<BaseException, List<PersonEntity>>> watchAll();

  Future<Either<BaseException, String>> save(
    PersonEntity person, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> delete(
    PersonEntity person, {
    required MemberEntity actor,
  });
}
