import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// An edit to a record that another device deleted meanwhile.
class RecordMissingCause extends BaseCause {
  RecordMissingCause({super.cause})
    : super(errorCode: CauseCode.recordMissing());
}
