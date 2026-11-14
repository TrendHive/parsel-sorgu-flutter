import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/interface/activity_repository_interface.dart';

/// The latest changes by anyone, newest first, as they happen.
///
/// [limit] keeps the page — and the free database's daily reads — bounded.
final class WatchActivityUseCase {
  const WatchActivityUseCase(this._activity);

  final ActivityRepositoryInterface _activity;

  static const int limit = 200;

  Stream<Either<BaseException, List<ActivityEntity>>> call() =>
      _activity.watchRecent(limit);
}
