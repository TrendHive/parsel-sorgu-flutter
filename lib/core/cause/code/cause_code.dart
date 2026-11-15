import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/admin_only_cause.dart';
import 'package:parcel_atlas/core/cause/drawing_overlaps_cause.dart';
import 'package:parcel_atlas/core/cause/email_exist_cause.dart';
import 'package:parcel_atlas/core/cause/empty_value_cause.dart';
import 'package:parcel_atlas/core/cause/family_loop_cause.dart';
import 'package:parcel_atlas/core/cause/invalid_credentials_cause.dart';
import 'package:parcel_atlas/core/cause/max_length_cause.dart';
import 'package:parcel_atlas/core/cause/min_length_cause.dart';
import 'package:parcel_atlas/core/cause/no_parcel_cause.dart';
import 'package:parcel_atlas/core/cause/not_member_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/cause/not_valid_email_cause.dart';
import 'package:parcel_atlas/core/cause/null_value_cause.dart';
import 'package:parcel_atlas/core/cause/record_missing_cause.dart';
import 'package:parcel_atlas/core/cause/registry_quota_cause.dart';
import 'package:parcel_atlas/core/cause/registry_refuses_web_cause.dart';
import 'package:parcel_atlas/core/cause/shares_exceed_whole_cause.dart';
import 'package:parcel_atlas/core/cause/split_misses_cause.dart';
import 'package:parcel_atlas/core/cause/token_expired_cause.dart';
import 'package:parcel_atlas/core/cause/too_few_corners_cause.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';

/// Why something failed, precisely — the fine half of a failure.
///
/// Each code names one [BaseCause]; [getCauseByCode] rebuilds the cause from
/// a stored or transmitted code.
class CauseCode {
  static const int unknownCode = 1001;
  static const int nullValueCode = 1002;
  static const int emptyValueCode = 1003;
  static const int minLengthCode = 1004;
  static const int maxLengthCode = 1005;
  static const int notValidEmailCode = 1006;
  static const int tokenExpiredCode = 1007;
  static const int emailExistCode = 1008;
  static const int invalidCredentialsCode = 1009;
  static const int notMemberCode = 1010;
  static const int adminOnlyCode = 1011;
  static const int notSignedInCode = 1012;
  static const int noParcelCode = 1013;
  static const int tooFewCornersCode = 1014;
  static const int recordMissingCode = 1015;
  static const int registryQuotaCode = 1016;
  static const int sharesExceedWholeCode = 1017;
  static const int familyLoopCode = 1018;
  static const int registryRefusesWebCode = 1019;
  static const int drawingOverlapsCode = 1020;
  static const int splitMissesCode = 1021;

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

  CauseCode.invalidCredentials() : code = invalidCredentialsCode;

  CauseCode.notMember() : code = notMemberCode;

  CauseCode.adminOnly() : code = adminOnlyCode;

  CauseCode.notSignedIn() : code = notSignedInCode;

  CauseCode.noParcel() : code = noParcelCode;

  CauseCode.tooFewCorners() : code = tooFewCornersCode;

  CauseCode.recordMissing() : code = recordMissingCode;

  CauseCode.registryQuota() : code = registryQuotaCode;

  CauseCode.sharesExceedWhole() : code = sharesExceedWholeCode;

  CauseCode.familyLoop() : code = familyLoopCode;

  CauseCode.registryRefusesWeb() : code = registryRefusesWebCode;

  CauseCode.drawingOverlaps() : code = drawingOverlapsCode;

  CauseCode.splitMisses() : code = splitMissesCode;

  BaseCause getCauseByCode() {
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
      case invalidCredentialsCode:
        return InvalidCredentialsCause();
      case notMemberCode:
        return NotMemberCause();
      case adminOnlyCode:
        return AdminOnlyCause();
      case notSignedInCode:
        return NotSignedInCause();
      case noParcelCode:
        return NoParcelCause();
      case tooFewCornersCode:
        return TooFewCornersCause();
      case recordMissingCode:
        return RecordMissingCause();
      case registryQuotaCode:
        return RegistryQuotaCause();
      case sharesExceedWholeCode:
        return SharesExceedWholeCause();
      case familyLoopCode:
        return FamilyLoopCause();
      case registryRefusesWebCode:
        return RegistryRefusesWebCause();
      case drawingOverlapsCode:
        return DrawingOverlapsCause();
      case splitMissesCode:
        return SplitMissesCause();
      default:
        return UnknownCause();
    }
  }
}
