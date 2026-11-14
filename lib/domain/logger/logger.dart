import 'package:parcel_atlas/core/logger/local_logger.dart';
import 'package:parcel_atlas/domain/package/model/package_model.dart';

class Logger {
  static PackageModel packageModel = PackageModel();

  static void debug(Object object, {StackTrace? stackTrace}) {
    LocalLogger.debug(object, stackTrace: stackTrace);
  }

  static void info(Object object) {
    LocalLogger.info(object);
  }

  static void warning(Object object, {StackTrace? stackTrace}) {
    LocalLogger.warning(object, stackTrace: stackTrace);
  }

  static Future<void> error(
    Object error, {
    StackTrace? stackTrace,
    String? language,
  }) async {
    LocalLogger.error(error, stackTrace: stackTrace);
  }
}
