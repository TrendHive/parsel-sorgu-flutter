import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// The official registry refused a lookup because it came from a website
/// other than its own. Lookups work from the desktop and mobile apps, which
/// are not websites; see `docs/tkgm-api.md`.
class RegistryRefusesWebCause extends BaseCause {
  RegistryRefusesWebCause({super.cause})
    : super(errorCode: CauseCode.registryRefusesWeb());
}
