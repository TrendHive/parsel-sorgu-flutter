import 'package:dio/dio.dart';

/// Wraps every answer in `{"data": ...}`, the envelope the services read.
class ManipulatorInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    response.data = {"data": response.data};
    super.onResponse(response, handler);
  }
}
