import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

class UnknownCause extends BaseCause {
  UnknownCause({super.cause}) : super(errorCode: CauseCode.unknown());
}
