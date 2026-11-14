import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/interface/person_group_repository_interface.dart';
import 'package:parcel_atlas/infrastructure/person/mapper/person_group_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/person/service/holder_cascade_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The family's groups in the store.
///
/// [delete] is one batch: the group, its lines on every drawing, and the
/// activity line.
class PersonGroupRepository implements PersonGroupRepositoryInterface {
  PersonGroupRepository(this._store) : _cascade = HolderCascade(_store);

  final FirestoreStoreService _store;

  final HolderCascade _cascade;

  static const PersonGroupDocumentMapper _mapper = PersonGroupDocumentMapper();

  @override
  Stream<Either<BaseException, List<PersonGroupEntity>>> watchAll() =>
      _store.watch(
        _store
            .collection(StoreCollection.groups)
            .orderBy(PersonGroupDocumentMapper.name),
        _mapper.read,
      );

  @override
  Future<Either<BaseException, String>> save(
    PersonGroupEntity group, {
    required MemberEntity actor,
  }) {
    final DocumentReference<Map<String, dynamic>> doc = group.isNew
        ? _store.doc(StoreCollection.groups)
        : _store.doc(StoreCollection.groups, group.id);
    final WriteBatch batch = _store.batch()
      ..set(doc, <String, Object?>{
        ..._mapper.write(group),
        PersonGroupDocumentMapper.updated: _store.stamps.write(actor),
        if (group.isNew)
          PersonGroupDocumentMapper.created: _store.stamps.write(actor),
      }, SetOptions(merge: true));
    _store.log(
      batch,
      action: group.isNew
          ? ActivityActionEnum.created
          : ActivityActionEnum.updated,
      target: ActivityTargetEnum.group,
      targetId: doc.id,
      label: group.name,
      actor: actor,
    );
    return _store.commit(batch, doc.id);
  }

  @override
  Future<Either<BaseException, String>> delete(
    PersonGroupEntity group, {
    required MemberEntity actor,
  }) async {
    final WriteBatch batch = _store.batch()
      ..delete(_store.doc(StoreCollection.groups, group.id));
    final Either<BaseException, int> drawings = await _cascade.removeFrom(
      batch,
      kind: HolderKindEnum.group,
      holderId: group.id,
      actor: actor,
    );
    if (drawings.isLeft) return Left(drawings.left);
    _store.log(
      batch,
      action: ActivityActionEnum.deleted,
      target: ActivityTargetEnum.group,
      targetId: group.id,
      label: group.name,
      actor: actor,
    );
    return _store.commit(batch, group.id);
  }
}
