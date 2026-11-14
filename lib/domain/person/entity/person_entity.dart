import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/validator/not_blank_validator.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/input/enum/input_field_enum.dart';

/// Someone parcels belong to — an owner, an heir, a tenant.
///
/// Not a member: a person never signs in. Members create people and assign
/// parcels to them. [create] answers a new, unsaved person (empty [id], no
/// stamps yet) or the reason it is not valid; [rename] the same for an edit.
final class PersonEntity extends BaseEntity {
  const PersonEntity({
    required this.id,
    required this.name,
    required this.note,
    required this.created,
    required this.updated,
  });

  @override
  final String id;

  final String name;

  final String note;

  final AuditStampValueObject? created;

  final AuditStampValueObject? updated;

  static Either<BaseException, PersonEntity> create({
    required String name,
    required String note,
  }) => NotBlankValidator(InputFieldEnum.personName.name)
      .validate(name)
      .map(
        (String valid) => PersonEntity(
          id: CoreConstants.empty,
          name: valid.trim(),
          note: note.trim(),
          created: null,
          updated: null,
        ),
      );

  Either<BaseException, PersonEntity> rename({
    required String name,
    required String note,
  }) => NotBlankValidator(InputFieldEnum.personName.name)
      .validate(name)
      .map(
        (String valid) => PersonEntity(
          id: id,
          name: valid.trim(),
          note: note.trim(),
          created: created,
          updated: updated,
        ),
      );

  bool get isNew => id.isEmpty;
}
