import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_dto.dart';
import 'package:parcel_atlas/core/base/base_mapper.dart';
import 'package:parcel_atlas/core/base/base_model.dart';

abstract class BaseUseCase<Model extends BaseModel, E> {
  BaseMapper<BaseDTO, Object?, Model> get mapper;

  Future<Either<E, Model>> execute(Model input);
}
