import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/validator/not_blank_validator.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/input/enum/input_field_enum.dart';

/// People who hold parcels together — four siblings who inherit everything
/// alike.
///
/// A parcel given to the group is shared equally among [memberIds]; changing
/// the members changes every such parcel at once. [create] answers a new,
/// unsaved group (empty [id]) or why it is not valid; [edit] the same for a
/// change.
final class PersonGroupEntity extends BaseEntity {
  const PersonGroupEntity({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.note,
    required this.created,
    required this.updated,
  });

  @override
  final String id;

  final String name;

  final List<String> memberIds;

  final String note;

  final AuditStampValueObject? created;

  final AuditStampValueObject? updated;

  static Either<BaseException, PersonGroupEntity> create({
    required String name,
    required List<String> memberIds,
    required String note,
  }) => NotBlankValidator(InputFieldEnum.groupName.name)
      .validate(name)
      .map(
        (String valid) => PersonGroupEntity(
          id: CoreConstants.empty,
          name: valid.trim(),
          memberIds: List<String>.unmodifiable(memberIds.toSet()),
          note: note.trim(),
          created: null,
          updated: null,
        ),
      );

  Either<BaseException, PersonGroupEntity> edit({
    required String name,
    required List<String> memberIds,
    required String note,
  }) => NotBlankValidator(InputFieldEnum.groupName.name)
      .validate(name)
      .map(
        (String valid) => PersonGroupEntity(
          id: id,
          name: valid.trim(),
          memberIds: List<String>.unmodifiable(memberIds.toSet()),
          note: note.trim(),
          created: created,
          updated: updated,
        ),
      );

  bool get isNew => id.isEmpty;

  bool hasMember(String personId) => memberIds.contains(personId);
}
