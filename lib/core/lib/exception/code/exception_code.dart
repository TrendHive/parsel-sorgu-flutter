class ExceptionCode {
  final int code;

  ExceptionCode(this.code);

  ExceptionCode.unknown() : code = 1001;

  ExceptionCode.badResponse() : code = 1002;

  ExceptionCode.internalServer() : code = 1003;

  ExceptionCode.auth() : code = 1004;

  ExceptionCode.network() : code = 1005;

  ExceptionCode.validation() : code = 1006;

  @override
  String toString() {
    return code.toString();
  }
}
