import 'package:core/base/base_cause.dart';
import 'package:core/cause/code/cause_code.dart';

class TokenExpiredCause extends BaseCause {
  TokenExpiredCause({super.cause}) : super(errorCode: CauseCode.tokenExpired());
}
