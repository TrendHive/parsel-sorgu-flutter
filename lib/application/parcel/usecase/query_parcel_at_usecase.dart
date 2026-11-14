import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';

/// "What parcel is here?" — answered from the family's store when it can be,
/// and from the registry only when nobody has fetched that parcel yet.
///
/// The registry allows few lookups a day, so a point inside a stored parcel
/// never reaches it: the stored parcel's id comes back at once. A point the
/// store does not cover is looked up once and saved, and the registry's answer
/// is keyed by parcel number, so a lookup landing on a parcel that another
/// device stored meanwhile updates that record instead of duplicating it.
///
/// Answers the parcel's id.
final class QueryParcelAtUseCase {
  const QueryParcelAtUseCase(this._auth, this._registry, this._parcels);

  final AuthRepositoryInterface _auth;

  final ParcelRegistryInterface _registry;

  final OfficialParcelRepositoryInterface _parcels;

  Future<Either<BaseException, String>> call(
    LatLng point,
    MapSnapshotReadModel snapshot,
  ) async {
    final OfficialParcelEntity? stored = snapshot.officialAt(point);
    if (stored != null) return Right(stored.id);

    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }

    final Either<BaseException, RegistryRecordValueObject> record =
        await _registry.fetchAt(point);
    return switch (record) {
      Left(:final BaseException value) => Left(value),
      Right(:final RegistryRecordValueObject value) => _parcels.saveRecord(
        value,
        actor: actor,
        isRefresh: snapshot.officialById(value.key) != null,
      ),
    };
  }
}
