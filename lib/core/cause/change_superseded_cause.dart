import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A change that cannot be undone because one of its records was changed
/// again afterwards (or the change was already undone): undoing it would
/// silently throw the newer change away.
class ChangeSupersededCause extends BaseCause {
  ChangeSupersededCause({super.cause})
    : super(errorCode: CauseCode.changeSuperseded());
}
