import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';

/// The family's whole store as one live snapshot: registry parcels, drawings
/// and people, re-emitted whenever any of them changes on any device.
///
/// Nothing is emitted until all three have answered once, so the map never
/// shows drawings whose people are still unknown. A failure on any stream is
/// passed on as it happens.
final class WatchMapUseCase {
  const WatchMapUseCase(this._officials, this._drawings, this._persons);

  final OfficialParcelRepositoryInterface _officials;

  final DrawnParcelRepositoryInterface _drawings;

  final PersonRepositoryInterface _persons;

  Stream<Either<BaseException, MapSnapshotReadModel>> call() {
    List<OfficialParcelEntity>? officials;
    List<DrawnParcelEntity>? drawings;
    List<PersonEntity>? persons;
    final List<StreamSubscription<Object?>> subscriptions =
        <StreamSubscription<Object?>>[];
    late final StreamController<Either<BaseException, MapSnapshotReadModel>>
    out;

    void publish() {
      if (officials == null || drawings == null || persons == null) return;
      out.add(
        Right(
          MapSnapshotReadModel(
            officials: officials!,
            drawings: drawings!,
            persons: persons!,
          ),
        ),
      );
    }

    void listen<T>(
      Stream<Either<BaseException, List<T>>> stream,
      void Function(List<T>) store,
    ) {
      subscriptions.add(
        stream.listen((Either<BaseException, List<T>> event) {
          switch (event) {
            case Left(:final BaseException value):
              out.add(Left(value));
            case Right(:final List<T> value):
              store(value);
              publish();
          }
        }),
      );
    }

    out = StreamController<Either<BaseException, MapSnapshotReadModel>>(
      onListen: () {
        listen<OfficialParcelEntity>(
          _officials.watchAll(),
          (List<OfficialParcelEntity> value) => officials = value,
        );
        listen<DrawnParcelEntity>(
          _drawings.watchAll(),
          (List<DrawnParcelEntity> value) => drawings = value,
        );
        listen<PersonEntity>(
          _persons.watchAll(),
          (List<PersonEntity> value) => persons = value,
        );
      },
      onCancel: () async {
        for (final StreamSubscription<Object?> s in subscriptions) {
          await s.cancel();
        }
        await out.close();
      },
    );
    return out.stream;
  }
}
