import 'package:dio/dio.dart';
//import 'package:infrastructure/cryptography/cryptography.dart';

class ManipulatorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.data = {"data": response.data};
    super.onResponse(response, handler);
  }
}
