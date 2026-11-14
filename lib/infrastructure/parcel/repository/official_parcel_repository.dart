import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/infrastructure/parcel/mapper/official_parcel_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// Registry parcels in the family store.
///
/// The only write is [saveRecord], and the document id is the parcel number,
/// so a parcel stored from two phones is one document. A refresh merges the
/// new answer over the old one: `created` (the first lookup) survives,
/// `refreshed` moves to now.
class OfficialParcelRepository implements OfficialParcelRepositoryInterface {
  OfficialParcelRepository(this._store);

  final FirestoreStoreService _store;

  static const OfficialParcelDocumentMapper _mapper =
      OfficialParcelDocumentMapper();

  @override
  Stream<Either<BaseException, List<OfficialParcelEntity>>> watchAll() => _store
      .watch(_store.collection(StoreCollection.officialParcels), _mapper.read);

  @override
  Future<Either<BaseException, String>> saveRecord(
    RegistryRecordValueObject record, {
    required MemberEntity actor,
    required bool isRefresh,
  }) {
    final WriteBatch batch = _store.batch();
    batch.set(
      _store.doc(StoreCollection.officialParcels, record.key),
      <String, Object?>{
        ..._mapper.writeRecord(record),
        OfficialParcelDocumentMapper.refreshed: _store.stamps.write(actor),
        if (!isRefresh)
          OfficialParcelDocumentMapper.created: _store.stamps.write(actor),
      },
      SetOptions(merge: true),
    );
    _store.log(
      batch,
      action: isRefresh
          ? ActivityActionEnum.refreshed
          : ActivityActionEnum.queried,
      target: ActivityTargetEnum.officialParcel,
      targetId: record.key,
      label: record.label,
      actor: actor,
    );
    return _store.commit(batch, record.key);
  }
}
