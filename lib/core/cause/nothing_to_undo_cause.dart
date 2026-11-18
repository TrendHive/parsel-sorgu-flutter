import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// No change that can be undone: none was found, or it is a registry lookup
/// or a change saved before undo existed.
class NothingToUndoCause extends BaseCause {
  NothingToUndoCause({super.cause})
    : super(errorCode: CauseCode.nothingToUndo());
}
