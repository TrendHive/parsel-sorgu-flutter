import 'package:logger/logger.dart' as log;

class LocalLogger {
  static final log.Logger logger = log.Logger();

  /// additional callback to be executed on error
  ///
  /// defaults to null
  static void Function(Object error, {StackTrace? stackTrace})? onError;

  /// additional callback to be executed on Severe Errors
  ///
  /// defaults to null
  static void Function(Object error, {StackTrace? stackTrace})? onSevere;

  static void init() {
    // init logger if needed
  }

  static void debug(Object object, {StackTrace? stackTrace}) {
    // ignore: avoid_dynamic_calls
    logger.d('', time: DateTime.now(), error: object, stackTrace: stackTrace);
  }

  static void info(Object object) {
    // ignore: avoid_dynamic_calls
    logger.i(object);
  }

  static void warning(Object object, {StackTrace? stackTrace}) {
    // ignore: avoid_dynamic_calls
    logger.w('', time: DateTime.now(), error: object, stackTrace: stackTrace);
  }

  /// a user made error, like bad api request, failed operations
  static void error(Object error, {StackTrace? stackTrace}) {
    // ignore: avoid_dynamic_calls
    logger.e('', time: DateTime.now(), error: error, stackTrace: stackTrace);
    onError?.call(error, stackTrace: stackTrace);
  }
}
