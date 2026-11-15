import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A cut that does not divide the drawing into pieces.
class SplitMissesCause extends BaseCause {
  SplitMissesCause({super.cause}) : super(errorCode: CauseCode.splitMisses());
}
