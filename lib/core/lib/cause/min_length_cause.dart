import 'package:core/base/base_cause.dart';
import 'package:core/cause/code/cause_code.dart';

class MinLengthCause extends BaseCause {
  MinLengthCause({super.cause}) : super(errorCode: CauseCode.minLength());
}
