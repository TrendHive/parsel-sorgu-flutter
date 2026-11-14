import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';

/// A registry parcel the family has looked up — read-only reference data.
///
/// Nothing here is the family's to edit: [record] is exactly what the
/// registry answered, and the only thing that changes it is asking the
/// registry again (the Refresh button). It exists to be looked at, compared against,
/// and copied as the starting shape of a drawing; people and notes belong to
/// the drawn boundary, which is the family's own.
///
/// [id] is the registry key, so two members querying the same parcel share
/// one record. [created] is the first lookup and [refreshed] the latest.
final class OfficialParcelEntity extends BaseEntity {
  const OfficialParcelEntity({
    required this.record,
    required this.created,
    required this.refreshed,
  });

  final RegistryRecordValueObject record;

  final AuditStampValueObject created;

  final AuditStampValueObject refreshed;

  @override
  String get id => record.key;

  String get label => record.label;
}
