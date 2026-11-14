import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';

/// The change log, newest first.
///
/// There is no write here on purpose: every repository that changes a record
/// writes its log line in the same atomic batch, so a change without a line —
/// or a line without its change — cannot exist.
abstract interface class ActivityRepositoryInterface {
  Stream<Either<BaseException, List<ActivityEntity>>> watchRecent(int limit);
}
