import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/parcel/rule/parcel_rules.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';

/// "Find block 114, parcel 1" — a parcel looked up by its number instead of
/// by a tap on the map.
///
/// The number is the parcel's key in the family's store, so a parcel
/// somebody already fetched is answered from there and the registry is not
/// asked. Only an unknown number spends one of the day's lookups, and its
/// answer is saved like any other.
///
/// Answers the parcel's id.
final class QueryParcelByNumberUseCase {
  const QueryParcelByNumberUseCase(this._auth, this._registry, this._parcels);

  final AuthRepositoryInterface _auth;

  final ParcelRegistryInterface _registry;

  final OfficialParcelRepositoryInterface _parcels;

  Future<Either<BaseException, String>> call({
    required int neighborhoodId,
    required String block,
    required String parcel,
    required MapSnapshotReadModel snapshot,
  }) async {
    final String key = ParcelRules.keyOf(
      neighborhoodId: neighborhoodId,
      block: block.trim(),
      parcel: parcel.trim(),
    );
    if (snapshot.officialById(key) != null) return Right(key);

    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    final Either<BaseException, RegistryRecordValueObject> record =
        await _registry.fetchByNumber(
          neighborhoodId: neighborhoodId,
          block: block.trim(),
          parcel: parcel.trim(),
        );
    return switch (record) {
      Left(:final BaseException value) => Left(value),
      Right(:final RegistryRecordValueObject value) => _parcels.saveRecord(
        value,
        actor: actor,
        isRefresh: false,
      ),
    };
  }
}
