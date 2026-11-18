import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// Drawings chosen for a merge that do not all share sides with each other,
/// so they do not join into one parcel.
class MergeMissesCause extends BaseCause {
  MergeMissesCause({super.cause}) : super(errorCode: CauseCode.mergeMisses());
}
