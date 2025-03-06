import 'package:core/base/base_exception.dart';
import 'package:core/base/base_repository.dart';
import 'package:core/base/base_request.dart';
import 'package:core/base/base_response.dart';
import 'package:core/cause/unknown_cause.dart';
import 'package:core/exception/network_exception.dart';
import 'package:core/exception/unknown_exception.dart';
import 'package:core/logger/local_logger.dart';
import 'package:either_dart/either.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class BaseRemoteRepository<Response extends BaseResponse,
    Request extends BaseRequest> extends BaseRepository {
  Future<Response> executer(BaseRequest request);

  @nonVirtual
  Future<Either<BaseException, Response>> execute(BaseRequest request) async {
    try {
      return Right(await executer(request));
    } on DioException catch (e, stackTrace) {
      LocalLogger.error(e, stackTrace: stackTrace);
      if (e.error is BaseException) {
        return Left(e.error as BaseException);
      } else {
        return Left(NetworkException(cause: UnknownCause(cause: e.message)));
      }
    } catch (e, stackTrace) {
      LocalLogger.error(e, stackTrace: stackTrace);
      return Left(UnknownException(cause: UnknownCause(cause: e)));
    }
  }
}
