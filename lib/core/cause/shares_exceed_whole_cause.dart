import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// Shares on one parcel that add up to more than the whole parcel, or a
/// single share that is not a proper fraction.
class SharesExceedWholeCause extends BaseCause {
  SharesExceedWholeCause({super.cause})
    : super(errorCode: CauseCode.sharesExceedWhole());
}
