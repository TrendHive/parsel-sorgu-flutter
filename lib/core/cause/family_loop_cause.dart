import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A parent link that would make a person their own ancestor.
class FamilyLoopCause extends BaseCause {
  FamilyLoopCause({super.cause}) : super(errorCode: CauseCode.familyLoop());
}
