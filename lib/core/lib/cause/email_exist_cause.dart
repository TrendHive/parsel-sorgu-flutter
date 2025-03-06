import 'package:core/base/base_cause.dart';
import 'package:core/cause/code/cause_code.dart';

class EmailExistCause extends BaseCause {
  EmailExistCause({super.cause}) : super(errorCode: CauseCode.emailExist());
}
