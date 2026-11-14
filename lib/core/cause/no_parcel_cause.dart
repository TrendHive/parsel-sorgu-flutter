import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A point where the official registry has no parcel.
class NoParcelCause extends BaseCause {
  NoParcelCause({super.cause}) : super(errorCode: CauseCode.noParcel());
}
