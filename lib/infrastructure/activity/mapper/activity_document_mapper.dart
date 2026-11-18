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
class ActivityDocumentMapper {
  const ActivityDocumentMapper();

  static const String by = 'by';
  static const String byAt = 'by.at';

  static const AuditStampMapper _stamps = AuditStampMapper();

  ActivityEntity? read(String id, Map<String, dynamic> data) {
    final ActivityActionEnum? action = ActivityActionEnum.values
        .where((ActivityActionEnum a) => a.name == data['action'])
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
