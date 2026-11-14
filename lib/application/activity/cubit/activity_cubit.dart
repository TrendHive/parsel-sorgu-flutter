import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/activity/usecase/watch_activity_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';

part 'activity_state.dart';

/// The change-log page: who changed what, live.
final class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(this._watchActivity) : super(const ActivityLoading());

  final WatchActivityUseCase _watchActivity;

  StreamSubscription<Either<BaseException, List<ActivityEntity>>>?
  _subscription;

  void start() {
    _subscription = _watchActivity().listen(
      (Either<BaseException, List<ActivityEntity>> event) =>
          emit(switch (event) {
            Left(:final BaseException value) => ActivityFailed(value),
            Right(:final List<ActivityEntity> value) => ActivityReady(value),
          }),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
