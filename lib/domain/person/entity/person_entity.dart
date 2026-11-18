import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/validator/not_blank_validator.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/input/enum/input_field_enum.dart';

/// Someone parcels belong to, and their place in the family tree.
///
/// Not a member: a person never signs in. [parentId] is the person's father
/// or mother in the tree, or null at its root. [spouseId] is the person's
/// husband or wife, when it is this person's record that names them — a
/// marriage is stored on one side only, and `FamilyRules.spouseOf` reads it
/// from either side. [passesToChildren] says the
/// person's shares have passed on: whatever they hold is split equally
/// among their children (and onward, if a child's share has passed on too).
/// A parcel recorded on a grandfather therefore reaches every heir without
/// being re-entered — and can later be compared with how the land was
/// really divided.
///
/// [initials] is what an avatar shows: the first letters of the first and
/// last word of the name ("Ada Lovelace" → "AL"), one letter for a single
/// word.
///
/// [create] answers a new, unsaved person (empty [id], no stamps yet) or the
/// reason it is not valid; [edit] the same for a change.
final class PersonEntity extends BaseEntity {
  const PersonEntity({
    required this.id,
    required this.name,
    required this.parentId,
    required this.spouseId,
    required this.passesToChildren,
    required this.note,
    required this.created,
    required this.updated,
  });

  @override
  final String id;

  final String name;

  final String? parentId;

  final String? spouseId;

  final bool passesToChildren;

  final String note;

  final AuditStampValueObject? created;

  final AuditStampValueObject? updated;

  static Either<BaseException, PersonEntity> create({
    required String name,
    required String? parentId,
    required String? spouseId,
    required bool passesToChildren,
    required String note,
  }) => NotBlankValidator(InputFieldEnum.personName.name)
      .validate(name)
      .map(
        (String valid) => PersonEntity(
          id: CoreConstants.empty,
          name: valid.trim(),
          parentId: parentId,
          spouseId: spouseId,
          passesToChildren: passesToChildren,
          note: note.trim(),
          created: null,
          updated: null,
        ),
      );

  Either<BaseException, PersonEntity> edit({
    required String name,
    required String? parentId,
    required String? spouseId,
    required bool passesToChildren,
    required String note,
  }) => NotBlankValidator(InputFieldEnum.personName.name)
      .validate(name)
      .map(
        (String valid) => PersonEntity(
          id: id,
          name: valid.trim(),
          parentId: parentId,
          spouseId: spouseId,
          passesToChildren: passesToChildren,
          note: note.trim(),
          created: created,
          updated: updated,
        ),
      );

  bool get isNew => id.isEmpty;

  String get initials {
    final List<String> words = name
        .trim()
        .split(CoreConstants.space)
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return CoreConstants.empty;
    final String first = String.fromCharCode(words.first.runes.first);
    final String last = words.length > 1
        ? String.fromCharCode(words.last.runes.first)
        : CoreConstants.empty;
    return (first + last).toUpperCase();
  }
}
