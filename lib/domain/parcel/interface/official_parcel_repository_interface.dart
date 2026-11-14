import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';

/// The family's shared store of registry parcels.
///
/// [watchAll] streams every stored parcel and re-emits on any change from any
/// device. [saveRecord] stores a registry answer — the only write there is:
/// a new parcel is created, a known one has its record replaced. There is no
/// edit and no delete, because a registry parcel is changed by the registry
/// and nobody else; Firestore's rules refuse both as well.
///
/// The write is signed by a [MemberEntity] and logs one activity line in the
/// same atomic batch.
abstract interface class OfficialParcelRepositoryInterface {
  Stream<Either<BaseException, List<OfficialParcelEntity>>> watchAll();

  Future<Either<BaseException, String>> saveRecord(
    RegistryRecordValueObject record, {
    required MemberEntity actor,
    required bool isRefresh,
  });
}
