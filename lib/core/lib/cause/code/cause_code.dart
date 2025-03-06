import 'package:core/base/base_cause.dart';
import 'package:core/cause/email_exist_cause.dart';
import 'package:core/cause/empty_value_cause.dart';
import 'package:core/cause/max_length_cause.dart';
import 'package:core/cause/min_length_cause.dart';
import 'package:core/cause/not_valid_email_cause.dart';
import 'package:core/cause/null_value_cause.dart';
import 'package:core/cause/token_expired_cause.dart';
import 'package:core/cause/unknown_cause.dart';

class CauseCode {
  static const int unknownCode = 1001;
  static const int nullValueCode = 1002;
  static const int emptyValueCode = 1003;
  static const int minLengthCode = 1004;
  static const int maxLengthCode = 1005;
  static const int notValidEmailCode = 1006;
  static const int tokenExpiredCode = 1007;
  static const int emailExistCode = 1008;


  final int code;

  CauseCode(this.code);

  CauseCode.unknown() : code = unknownCode;

  CauseCode.nullValue() : code = nullValueCode;

  CauseCode.emptyValue() : code = emptyValueCode;

  CauseCode.minLength() : code = minLengthCode;

  CauseCode.maxLength() : code = maxLengthCode;

  CauseCode.notValidEmail() : code = notValidEmailCode;

  CauseCode.tokenExpired() : code = tokenExpiredCode;

  CauseCode.emailExist() : code = emailExistCode;

  BaseCause getCauseByCode(){
      switch (code) {
      case unknownCode:
        return UnknownCause();
      case nullValueCode:
        return NullValueCause();
      case emptyValueCode:
        return EmptyCause();
      case minLengthCode:
        return MinLengthCause();
      case maxLengthCode:
        return MaxLengthCause();
      case notValidEmailCode:
        return NotValidEmailCause();
      case tokenExpiredCode:
        return TokenExpiredCause();
      case emailExistCode:
        return EmailExistCause();
      default:
        return UnknownCause();
    }
  }
}
