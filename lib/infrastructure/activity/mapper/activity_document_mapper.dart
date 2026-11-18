import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';

/// An activity line from the store. Lines are written by
/// `FirestoreStoreService.log` and never edited, so there is only [read]. A
/// line counts as part of an undoable change only when it names both the
/// change and the record's path.
///
/// [leftAsChanged] says a record is still exactly as `line`'s change left
/// it: gone, for a change that deleted it; otherwise stamped `updated` at
/// the change's own time — every write in one batch gets the same server
/// time, and any later write (from any app version or tool) moves it. Undo
/// refuses a record for which this is false, so a newer edit is never
/// overwritten.
class ActivityDocumentMapper {
  const ActivityDocumentMapper();

  static const String by = 'by';
  static const String byAt = 'by.at';

  static const AuditStampMapper _stamps = AuditStampMapper();

  static bool leftAsChanged({
    required Map<String, dynamic>? now,
    required Map<String, dynamic> line,
  }) {
    if (line[_action] == ActivityActionEnum.deleted.name) return now == null;
    final Timestamp? changedAt = _at(line[by]);
    final Timestamp? updatedAt = _at(now?[_updated]);
    return changedAt != null && updatedAt != null && changedAt == updatedAt;
  }

  static Timestamp? _at(Object? stamp) {
    final Object? at = stamp is Map<String, dynamic>
        ? stamp[AuditStampMapper.at]
        : null;
    return at is Timestamp ? at : null;
  }

  static const String _action = 'action';
  static const String _updated = 'updated';

  ActivityEntity? read(String id, Map<String, dynamic> data) {
    final ActivityActionEnum? action = ActivityActionEnum.values
        .where((ActivityActionEnum a) => a.name == data[_action])
        .firstOrNull;
    final ActivityTargetEnum? target = ActivityTargetEnum.values
        .where((ActivityTargetEnum t) => t.name == data['target'])
        .firstOrNull;
    if (action == null || target == null) return null;
    return ActivityEntity(
      id: id,
      action: action,
      target: target,
      targetId: '${data['targetId'] ?? CoreConstants.empty}',
      label: '${data['label'] ?? CoreConstants.empty}',
      stamp: _stamps.read(data[by]),
      changeId:
          data[FirestoreStoreService.path] is String &&
              data[FirestoreStoreService.changeId] is String
          ? data[FirestoreStoreService.changeId] as String
          : null,
      isUndo: data[FirestoreStoreService.undo] == true,
    );
  }
}
