import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A spouse link to the person themselves, to their own ancestor or
/// descendant, or to someone already married to another person.
class SpouseNotAllowedCause extends BaseCause {
  SpouseNotAllowedCause({super.cause})
    : super(errorCode: CauseCode.spouseNotAllowed());
}
