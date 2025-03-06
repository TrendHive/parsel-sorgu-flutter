import 'package:core/base/base_request.dart';
import 'package:core/base/base_response.dart';

abstract class BaseService {
  String get endpoint;
  Future<BaseResponse> execute(BaseRequest request);
}
