import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A signed-in account the family's member list does not hold.
class NotMemberCause extends BaseCause {
  NotMemberCause({super.cause}) : super(errorCode: CauseCode.notMember());
}
