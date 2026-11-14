import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// An action attempted while nobody is signed in.
class NotSignedInCause extends BaseCause {
  NotSignedInCause({super.cause}) : super(errorCode: CauseCode.notSignedIn());
}
