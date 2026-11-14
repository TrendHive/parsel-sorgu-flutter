import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A username and password that do not match an account.
class InvalidCredentialsCause extends BaseCause {
  InvalidCredentialsCause({super.cause})
    : super(errorCode: CauseCode.invalidCredentials());
}
