import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A drawing with fewer corners than a polygon needs to enclose an area.
class TooFewCornersCause extends BaseCause {
  TooFewCornersCause({super.cause})
    : super(errorCode: CauseCode.tooFewCorners());
}
