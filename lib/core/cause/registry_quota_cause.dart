import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// The official registry's daily query allowance for this connection is spent.
class RegistryQuotaCause extends BaseCause {
  RegistryQuotaCause({super.cause})
    : super(errorCode: CauseCode.registryQuota());
}
