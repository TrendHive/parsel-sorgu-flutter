/// What kind of thing went wrong — the coarse half of a failure.
///
/// The fine half is the `BaseCause`'s `CauseCode`: an exception says
/// "validation", its cause says "this name is empty". The presentation layer
/// picks the words from the cause first and falls back to the exception.
class ExceptionCode {
  static const int unknownCode = 1001;
  static const int badResponseCode = 1002;
  static const int internalServerCode = 1003;
  static const int authCode = 1004;
  static const int networkCode = 1005;
  static const int validationCode = 1006;
  static const int notFoundCode = 1007;
  static const int quotaExceededCode = 1008;

  final int code;

  ExceptionCode(this.code);

  ExceptionCode.unknown() : code = unknownCode;

  ExceptionCode.badResponse() : code = badResponseCode;

  ExceptionCode.internalServer() : code = internalServerCode;

  ExceptionCode.auth() : code = authCode;

  ExceptionCode.network() : code = networkCode;

  ExceptionCode.validation() : code = validationCode;

  ExceptionCode.notFound() : code = notFoundCode;

  ExceptionCode.quotaExceeded() : code = quotaExceededCode;

  @override
  String toString() {
    return code.toString();
  }
}
