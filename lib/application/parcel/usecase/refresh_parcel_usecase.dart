import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';

/// The Refresh button: asks the registry again for a stored parcel and replaces its
/// record with the answer — the only way a registry parcel ever changes.
///
/// It asks by parcel number rather than by a point, so it fetches exactly the
/// parcel on screen, never a neighbour whose border a point happened to cross.
/// One registry lookup, spent only when a member asks for it.
final class RefreshParcelUseCase {
  const RefreshParcelUseCase(this._auth, this._registry, this._parcels);

  final AuthRepositoryInterface _auth;

  final ParcelRegistryInterface _registry;

  final OfficialParcelRepositoryInterface _parcels;

  Future<Either<BaseException, String>> call(
    OfficialParcelEntity parcel,
  ) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    final Either<BaseException, RegistryRecordValueObject> record =
        await _registry.fetchByNumber(
          neighborhoodId: parcel.record.neighborhoodId,
          block: parcel.record.block,
          parcel: parcel.record.parcel,
        );
    return switch (record) {
      Left(:final BaseException value) => Left(value),
      Right(:final RegistryRecordValueObject value) => _parcels.saveRecord(
        value,
        actor: actor,
        isRefresh: true,
      ),
    };
  }
}
