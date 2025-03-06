import 'package:core/cause/code/cause_code.dart';

abstract class BaseCause {
  final CauseCode? errorCode;
  dynamic cause;

  BaseCause({this.errorCode, this.cause});
}
