import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_table_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';

part 'compare_state.dart';

/// The comparison page: the parcels put aside on the map, side by side, and
/// each owner's real and deed area over them — recomputed live whenever a
/// parcel, a share or the tree changes on any device.
final class CompareCubit extends Cubit<CompareState> {
  CompareCubit(this._watchMap) : super(const CompareLoading());

  final WatchMapUseCase _watchMap;

  StreamSubscription<Either<BaseException, MapSnapshotReadModel>>?
  _subscription;

  void start({required List<String> ids}) {
    _subscription = _watchMap().listen((
      Either<BaseException, MapSnapshotReadModel> event,
    ) {
      emit(switch (event) {
        Left(:final BaseException value) => CompareFailed(value),
        Right(:final MapSnapshotReadModel value) => CompareReady(
          value.compare(ids),
        ),
      });
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
