import 'package:core/base/base_cause.dart';
import 'package:core/cause/code/cause_code.dart';

class EmptyCause extends BaseCause {
  EmptyCause({super.cause}) : super(errorCode: CauseCode.emptyValue());
}
