import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';

/// Writes and reads the who-and-when stamp every record carries.
///
/// [write] stamps with the server's clock, not the device's, so changes from
/// two phones order correctly even when one phone's clock is wrong — and
/// `firestore.rules` checks the stamp names the signed-in member at the
/// request's own time.
///
/// [read] answers a time the server has not filled in yet — a write still on
/// its way, seen through the local cache — as now, which is what it will be
/// within a second; a record that is not a stamp at all reads as the epoch
/// rather than failing a whole list over one odd document.
class AuditStampMapper {
  const AuditStampMapper();

  static const String memberId = 'memberId';
  static const String memberName = 'memberName';
  static const String at = 'at';

  Map<String, Object?> write(MemberEntity actor) => <String, Object?>{
    memberId: actor.id,
    memberName: actor.name,
    at: FieldValue.serverTimestamp(),
  };

  AuditStampValueObject read(Object? raw) {
    final Map<String, dynamic> map = raw is Map<String, dynamic>
        ? raw
        : const <String, dynamic>{};
    final Object? time = map[at];
    return AuditStampValueObject(
      memberId: '${map[memberId] ?? CoreConstants.empty}',
      memberName: '${map[memberName] ?? CoreConstants.empty}',
      at: time is Timestamp
          ? time.toDate()
          : map.containsKey(at)
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(CoreConstants.zero),
    );
  }

  AuditStampValueObject? readOptional(Object? raw) =>
      raw is Map<String, dynamic> ? read(raw) : null;
}
