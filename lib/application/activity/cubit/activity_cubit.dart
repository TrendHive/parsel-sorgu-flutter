import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/activity/usecase/undo_change_usecase.dart';
import 'package:parcel_atlas/application/activity/usecase/watch_activity_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';

part 'activity_state.dart';

/// The change-log page: who changed what, live — and [undo] for any change
/// that remembers its records.
final class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(this._watchActivity, this._undoChange)
    : super(const ActivityLoading());

  final WatchActivityUseCase _watchActivity;

  final UndoChangeUseCase _undoChange;

  StreamSubscription<Either<BaseException, List<ActivityEntity>>>?
  _subscription;

  void start() {
    _subscription = _watchActivity().listen(
      (Either<BaseException, List<ActivityEntity>> event) =>
          emit(switch (event) {
            Left(:final BaseException value) => ActivityFailed(value),
            Right(:final List<ActivityEntity> value) => switch (state) {
              final ActivityReady ready => ready.withEntries(value),
              _ => ActivityReady(value),
            },
          }),
    );
  }

  Future<void> undo(String changeId) async {
    final ActivityState before = state;
    if (before is! ActivityReady || before.undoing) return;
    emit(before.whileUndoing());
    final Either<BaseException, String> result = await _undoChange(
      changeId: changeId,
    );
    final ActivityState current = state;
    if (isClosed || current is! ActivityReady) return;
    emit(current.withResult(result));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
