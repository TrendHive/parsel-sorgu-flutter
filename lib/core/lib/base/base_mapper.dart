import 'package:core/base/base_dto.dart';
import 'package:core/base/base_exception.dart';
import 'package:core/base/base_model.dart';
import 'package:core/exception/unknown_exception.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

abstract class BaseMapper<RequestDTO extends BaseDTO, ResponseDTO,
    M extends BaseModel> {
  RequestDTO createFromModel(M model);
  M modelUpdater(M model, ResponseDTO dto);

  @nonVirtual
  Either<BaseException, M> updateModel(M model, ResponseDTO dto) {
    try {
      return Right(modelUpdater(model, dto));
    } on BaseException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownException());
    }
  }
}
