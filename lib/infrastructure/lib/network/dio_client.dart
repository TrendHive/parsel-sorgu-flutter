import 'package:dio/dio.dart';
import 'package:infrastructure/constants.dart';
import 'package:infrastructure/network/interceptors/error_interceptor.dart';
import 'package:infrastructure/network/interceptors/manipulator_interceptor.dart';

class DioClient {
  DioClient()
      : dio = Dio(
          BaseOptions(
              baseUrl: InfrastructureConstants.baseURL +
                  InfrastructureConstants.api),
        ) {
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(ManipulatorInterceptor());
    dio.interceptors.add(LogInterceptor());
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  final Dio dio;
}
