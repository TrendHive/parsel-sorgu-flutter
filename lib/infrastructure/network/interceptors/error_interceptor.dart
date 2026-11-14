import 'package:dio/dio.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/no_parcel_cause.dart';
import 'package:parcel_atlas/core/cause/registry_quota_cause.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';
import 'package:parcel_atlas/core/exception/bad_response_exception.dart';
import 'package:parcel_atlas/core/exception/network_exception.dart';
import 'package:parcel_atlas/core/exception/not_found_exception.dart';
import 'package:parcel_atlas/core/exception/quota_exceeded_exception.dart';
import 'package:parcel_atlas/infrastructure/constants.dart';

/// Turns every Dio failure into the app's own [BaseException], carried in
/// `DioException.error`, where `BaseRemoteRepository` picks it up.
///
/// A bad response is told apart by status: the registry's daily limit
/// becomes a [QuotaExceededException] (the screen says "try tomorrow", not
/// "something went wrong") and a point with no parcel a
/// [NotFoundException]. Connection problems of every kind are a
/// [NetworkException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final BaseException? exception = switch (err.type) {
      DioExceptionType.badResponse => _fromStatus(err),
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel ||
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.transformTimeout => NetworkException(
        cause: UnknownCause(cause: err.message),
      ),
      DioExceptionType.unknown => null,
    };
    super.onError(
      exception == null
          ? err
          : DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: exception,
              stackTrace: err.stackTrace,
              message: err.message,
            ),
      handler,
    );
  }

  BaseException _fromStatus(DioException err) =>
      switch (err.response?.statusCode) {
        InfrastructureConstants.quotaStatus => QuotaExceededException(
          cause: RegistryQuotaCause(),
        ),
        InfrastructureConstants.notFoundStatus => NotFoundException(
          cause: NoParcelCause(),
        ),
        _ => BadResponseException(
          cause: UnknownCause(cause: err.response?.data),
        ),
      };
}
