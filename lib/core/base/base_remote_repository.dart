import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:parcel_atlas/core/base/base_dto.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/base/base_repository.dart';
import 'package:parcel_atlas/core/base/base_request.dart';
import 'package:parcel_atlas/core/base/base_response.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';
import 'package:parcel_atlas/core/exception/network_exception.dart';
import 'package:parcel_atlas/core/exception/unknown_exception.dart';
import 'package:parcel_atlas/core/logger/local_logger.dart';

abstract class BaseRemoteRepository<
  R extends BaseResponse<BaseDTO>,
  Q extends BaseRequest
>
    extends BaseRepository {
  Future<R> executer(BaseRequest request);

  @nonVirtual
  Future<Either<BaseException, R>> execute(BaseRequest request) async {
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
