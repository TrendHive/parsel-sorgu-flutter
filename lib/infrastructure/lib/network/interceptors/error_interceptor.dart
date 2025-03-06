import 'package:core/cause/unknown_cause.dart';
import 'package:core/exception/bad_response_exception.dart';
import 'package:core/exception/network_exception.dart';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.badCertificate:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: NetworkException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.badResponse:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: BadResponseException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.cancel:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: NetworkException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.connectionError:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: NetworkException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.connectionTimeout:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: NetworkException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.receiveTimeout:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: NetworkException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.sendTimeout:
        super.onError(
            DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: NetworkException(cause: UnknownCause(cause: err.response?.data)),
                stackTrace: err.stackTrace,
                message: err.message),
            handler);
        break;
      case DioExceptionType.unknown:
        super.onError(err, handler);
        break;
    }
  }
}
