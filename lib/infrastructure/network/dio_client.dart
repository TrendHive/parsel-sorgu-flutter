import 'package:dio/dio.dart';
import 'package:parcel_atlas/infrastructure/constants.dart';
import 'package:parcel_atlas/infrastructure/network/interceptors/error_interceptor.dart';
import 'package:parcel_atlas/infrastructure/network/interceptors/manipulator_interceptor.dart';

/// The HTTP client for the external registry.
///
/// No `Content-Type` or custom header is set: a GET with only simple headers
/// is a "simple" cross-origin request, so the browser sends it as it is —
/// one request per lookup — instead of a preflight `OPTIONS` first. The
/// registry allows few lookups a day; doubling the traffic would only invite
/// its limit sooner.
class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl:
              InfrastructureConstants.baseURL + InfrastructureConstants.api,
          connectTimeout: InfrastructureConstants.registryTimeout,
          receiveTimeout: InfrastructureConstants.registryTimeout,
        ),
      ) {
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(ManipulatorInterceptor());
  }

  final Dio dio;
}
