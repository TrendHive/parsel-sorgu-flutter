import 'package:parcel_atlas/core/base/base_value_object.dart';
import 'package:parcel_atlas/core/base/base_value_validator.dart';

/// Who did something, and when — the signature on every record.
///
/// [memberName] is copied at the time of the change rather than looked up
/// later, so a record keeps saying who changed it even if that member's
/// account is renamed or removed.
final class AuditStampValueObject
    extends
        BaseValueObject<({String memberId, String memberName, DateTime at})> {
  const AuditStampValueObject({
    required String memberId,
    required String memberName,
    required DateTime at,
  }) : super((memberId: memberId, memberName: memberName, at: at));

  @override
  List<BaseValueValidator<({String memberId, String memberName, DateTime at})>>
  get validators =>
      const <
        BaseValueValidator<({String memberId, String memberName, DateTime at})>
      >[];

  String get memberId => value.memberId;

  String get memberName => value.memberName;

  DateTime get at => value.at;
}
