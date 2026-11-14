import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/infrastructure/drawing/mapper/drawn_parcel_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// Takes a deleted person's or group's ownership lines off every drawing,
/// inside the caller's batch, so the delete and the clean-up are one atomic
/// change.
///
/// [removeFrom] finds the drawings through `ownerKeys` and rewrites each
/// one's owners without the holder, stamping the change with the [MemberEntity].
class HolderCascade {
  const HolderCascade(this._store);

  final FirestoreStoreService _store;

  static const DrawnParcelDocumentMapper _drawings =
      DrawnParcelDocumentMapper();

  Future<Either<BaseException, int>> removeFrom(
    WriteBatch batch, {
    required HolderKindEnum kind,
    required String holderId,
    required MemberEntity actor,
  }) async {
    final Either<
      BaseException,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
    >
    found = await _store.query(
      _store
          .collection(StoreCollection.drawnParcels)
          .where(
            DrawnParcelDocumentMapper.ownerKeys,
            arrayContains: DrawnParcelDocumentMapper.ownerKey(kind, holderId),
          ),
    );
    if (found.isLeft) return Left(found.left);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in found.right) {
      final DrawnParcelEntity? drawing = _drawings.read(doc.id, doc.data());
      if (drawing == null) continue;
      final List<OwnershipValueObject> kept = drawing.owners
          .where((OwnershipValueObject line) => !line.holds(kind, holderId))
          .toList();
      batch.update(doc.reference, <String, Object?>{
        DrawnParcelDocumentMapper.owners: _drawings.writeOwners(kept),
        DrawnParcelDocumentMapper.ownerKeys: _drawings.writeOwnerKeys(kept),
        DrawnParcelDocumentMapper.updated: _store.stamps.write(actor),
      });
    }
    return Right(found.right.length);
  }
}
