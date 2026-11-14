import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/record_missing_cause.dart';
import 'package:parcel_atlas/core/exception/not_found_exception.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';

part 'holdings_state.dart';

/// The holdings page: everything one person or one group holds, with where
/// each parcel is, its area, the share held and the totals — recomputed live
/// whenever any parcel, share or group changes on any device.
final class HoldingsCubit extends Cubit<HoldingsState> {
  HoldingsCubit(this._watchMap) : super(const HoldingsLoading());

  final WatchMapUseCase _watchMap;

  StreamSubscription<Either<BaseException, MapSnapshotReadModel>>?
  _subscription;

  void start({required HolderKindEnum kind, required String id}) {
    _subscription = _watchMap().listen((
      Either<BaseException, MapSnapshotReadModel> event,
    ) {
      switch (event) {
        case Left(:final BaseException value):
          emit(HoldingsFailed(value));
        case Right(:final MapSnapshotReadModel value):
          emit(_holdings(value, kind, id));
      }
    });
  }

  HoldingsState _holdings(
    MapSnapshotReadModel snapshot,
    HolderKindEnum kind,
    String id,
  ) {
    switch (kind) {
      case HolderKindEnum.person:
        final PersonEntity? person = snapshot.personById(id);
        if (person == null) {
          return HoldingsFailed(NotFoundException(cause: RecordMissingCause()));
        }
        return HoldingsReady(
          title: person.name,
          holdings: snapshot.holdingsOfPerson(id),
          members: const <PersonEntity>[],
          groups: snapshot.groupsOf(id),
        );
      case HolderKindEnum.group:
        final PersonGroupEntity? group = snapshot.groupById(id);
        if (group == null) {
          return HoldingsFailed(NotFoundException(cause: RecordMissingCause()));
        }
        return HoldingsReady(
          title: group.name,
          holdings: snapshot.holdingsOfGroup(id),
          members: <PersonEntity>[
            for (final String memberId in group.memberIds)
              ?snapshot.personById(memberId),
          ],
          groups: const <PersonGroupEntity>[],
        );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
