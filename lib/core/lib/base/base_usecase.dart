import 'package:core/base/base_mapper.dart';
import 'package:core/base/base_model.dart';
import 'package:either_dart/either.dart';

abstract class BaseUseCase<Model extends BaseModel, Exception> {
  BaseMapper get mapper;

  Future<Either<Exception, Model>> execute(Model input);
}
