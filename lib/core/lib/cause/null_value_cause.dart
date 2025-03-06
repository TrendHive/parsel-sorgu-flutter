import 'package:core/base/base_cause.dart';
import 'package:core/cause/code/cause_code.dart';

class NullValueCause extends BaseCause {
  NullValueCause({super.cause}) : super(errorCode: CauseCode.nullValue());
}
