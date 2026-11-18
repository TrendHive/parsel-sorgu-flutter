import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/record_missing_cause.dart';
import 'package:parcel_atlas/core/exception/not_found_exception.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/read_model/holdings_read_model.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';

part 'holdings_state.dart';

/// The holdings page: everything that reaches one person — recorded on them
/// or inherited down the family tree — with where each parcel is, its area,
/// the share and the totals, recomputed live whenever a parcel, a share or
/// the tree changes on any device.
final class HoldingsCubit extends Cubit<HoldingsState> {
  HoldingsCubit(this._watchMap) : super(const HoldingsLoading());

  final WatchMapUseCase _watchMap;

  StreamSubscription<Either<BaseException, MapSnapshotReadModel>>?
  _subscription;

  void start({required String personId}) {
    _subscription = _watchMap().listen((
      Either<BaseException, MapSnapshotReadModel> event,
    ) {
      switch (event) {
        case Left(:final BaseException value):
          emit(HoldingsFailed(value));
        case Right(:final MapSnapshotReadModel value):
          final PersonEntity? person = value.personById(personId);
          emit(
            person == null
                ? HoldingsFailed(NotFoundException(cause: RecordMissingCause()))
                : HoldingsReady(
                    person: person,
                    holdings: value.holdingsOfPerson(personId),
                    parent: person.parentId == null
                        ? null
                        : value.personById(person.parentId!),
                    spouse: FamilyRules.spouseOf(value.persons, person),
                    children: FamilyRules.familyChildrenOf(
                      value.persons,
                      person,
                    ),
                    passedOn: FamilyRules.passes(value.persons, person),
                  ),
          );
      }
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
