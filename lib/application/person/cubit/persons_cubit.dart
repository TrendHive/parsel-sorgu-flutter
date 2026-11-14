import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/application/person/usecase/delete_group_usecase.dart';
import 'package:parcel_atlas/application/person/usecase/delete_person_usecase.dart';
import 'package:parcel_atlas/application/person/usecase/save_group_usecase.dart';
import 'package:parcel_atlas/application/person/usecase/save_person_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';

part 'persons_state.dart';

/// The people page: everyone the family assigns parcels to, the groups they
/// form, and what each holds — live from the shared store.
final class PersonsCubit extends Cubit<PersonsState> {
  PersonsCubit(
    this._watchMap,
    this._savePerson,
    this._deletePerson,
    this._saveGroup,
    this._deleteGroup,
    this._auth,
  ) : super(const PersonsLoading());

  final WatchMapUseCase _watchMap;

  final SavePersonUseCase _savePerson;

  final DeletePersonUseCase _deletePerson;

  final SaveGroupUseCase _saveGroup;

  final DeleteGroupUseCase _deleteGroup;

  final AuthRepositoryInterface _auth;

  StreamSubscription<Either<BaseException, MapSnapshotReadModel>>?
  _subscription;

  void start() {
    _subscription = _watchMap().listen((
      Either<BaseException, MapSnapshotReadModel> event,
    ) {
      final PersonsState current = state;
      switch (event) {
        case Left(:final BaseException value):
          if (current is! PersonsReady) emit(PersonsFailed(value));
        case Right(:final MapSnapshotReadModel value):
          emit(
            current is PersonsReady
                ? current.withSnapshot(value)
                : PersonsReady(snapshot: value, member: _auth.currentMember),
          );
      }
    });
  }

  Future<void> savePerson({
    required String name,
    required String note,
    PersonEntity? existing,
  }) async =>
      _report(await _savePerson(name: name, note: note, existing: existing));

  Future<void> deletePerson(PersonEntity person) async =>
      _report(await _deletePerson(person));

  Future<void> saveGroup({
    required String name,
    required List<String> memberIds,
    required String note,
    PersonGroupEntity? existing,
  }) async => _report(
    await _saveGroup(
      name: name,
      memberIds: memberIds,
      note: note,
      existing: existing,
    ),
  );

  Future<void> deleteGroup(PersonGroupEntity group) async =>
      _report(await _deleteGroup(group));

  void _report(Either<BaseException, String> result) {
    final PersonsState current = state;
    if (!isClosed && current is PersonsReady) emit(current.withResult(result));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
