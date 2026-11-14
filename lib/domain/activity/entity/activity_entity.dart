import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';

/// One line of the family's change log: who did what, to which record.
///
/// [label] is the record's name at the time ("114/1", "Ahmet"), copied so the
/// line still reads after the record is renamed or deleted. Entries are only
/// ever added — the log is the answer to "who changed this?", and an editable
/// log could not give it.
final class ActivityEntity extends BaseEntity {
  const ActivityEntity({
    required this.id,
    required this.action,
    required this.target,
    required this.targetId,
    required this.label,
    required this.stamp,
  });

  @override
  final String id;

  final ActivityActionEnum action;

  final ActivityTargetEnum target;

  final String targetId;

  final String label;

  final AuditStampValueObject stamp;
}
