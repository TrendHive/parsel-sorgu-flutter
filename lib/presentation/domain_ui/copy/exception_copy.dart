import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';
import 'package:parcel_atlas/core/exception/code/exception_code.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';

/// The one place an exception becomes words.
///
/// The cause decides first — it is the precise reason ("too few corners");
/// the exception's kind is the fallback ("no connection"). A new cause that
/// is not listed here reads as the generic message rather than as a code.
class ExceptionCopy {
  ExceptionCopy._();

  static String of(AppLocalizations l10n, BaseException exception) {
    final int? cause = exception.cause?.errorCode?.code;
    final String? byCause = switch (cause) {
      CauseCode.invalidCredentialsCode => l10n.errorInvalidCredentials,
      CauseCode.notMemberCode => l10n.errorNotMember,
      CauseCode.adminOnlyCode => l10n.errorAdminOnly,
      CauseCode.notSignedInCode => l10n.errorNotSignedIn,
      CauseCode.noParcelCode => l10n.errorNoParcel,
      CauseCode.tooFewCornersCode => l10n.errorTooFewCorners,
      CauseCode.recordMissingCode => l10n.errorRecordMissing,
      CauseCode.registryQuotaCode => l10n.errorQuota,
      CauseCode.sharesExceedWholeCode => l10n.errorSharesExceed,
      CauseCode.familyLoopCode => l10n.errorFamilyLoop,
      CauseCode.registryRefusesWebCode => l10n.errorRegistryRefusesWeb,
      CauseCode.drawingOverlapsCode => l10n.errorDrawingOverlaps,
      CauseCode.splitMissesCode => l10n.errorSplitMisses,
      CauseCode.emptyValueCode => l10n.errorEmptyField,
      _ => null,
    };
    if (byCause != null) return byCause;
    return switch (exception.code?.code) {
      ExceptionCode.networkCode => l10n.errorNetwork,
      ExceptionCode.quotaExceededCode => l10n.errorQuota,
      ExceptionCode.notFoundCode => l10n.errorNoParcel,
      ExceptionCode.badResponseCode => l10n.errorBadResponse,
      _ => l10n.errorUnknown,
    };
  }
}
