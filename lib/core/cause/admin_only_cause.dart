import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// An action only the main (admin) account may take, such as deleting.
class AdminOnlyCause extends BaseCause {
  AdminOnlyCause({super.cause}) : super(errorCode: CauseCode.adminOnly());
}
