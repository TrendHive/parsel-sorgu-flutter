import 'package:core/base/base_cause.dart';
import 'package:core/cause/code/cause_code.dart';

class NotValidEmailCause extends BaseCause {
  NotValidEmailCause({super.cause}) : super(errorCode: CauseCode.notValidEmail());
}
