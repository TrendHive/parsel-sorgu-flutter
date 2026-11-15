import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';
import 'package:parcel_atlas/infrastructure/person/mapper/person_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/person/service/holder_cascade_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The family's people in the store.
///
/// [delete] is one batch: the person, their lines on every drawing, their
/// children's link to them, and the activity line.
class PersonRepository implements PersonRepositoryInterface {
  PersonRepository(this._store) : _cascade = HolderCascade(_store);

  final FirestoreStoreService _store;

  final HolderCascade _cascade;

  static const PersonDocumentMapper _mapper = PersonDocumentMapper();

  @override
  Stream<Either<BaseException, List<PersonEntity>>> watchAll() => _store.watch(
    _store
        .collection(StoreCollection.persons)
        .orderBy(PersonDocumentMapper.name),
    _mapper.read,
  );

  @override
  Future<Either<BaseException, String>> save(
    PersonEntity person, {
    required MemberEntity actor,
  }) {
    final DocumentReference<Map<String, dynamic>> doc = person.isNew
        ? _store.doc(StoreCollection.persons)
        : _store.doc(StoreCollection.persons, person.id);
    final WriteBatch batch = _store.batch()
      ..set(doc, <String, Object?>{
        ..._mapper.write(person),
        PersonDocumentMapper.updated: _store.stamps.write(actor),
        if (person.isNew)
          PersonDocumentMapper.created: _store.stamps.write(actor),
      }, SetOptions(merge: true));
    _store.log(
      batch,
      action: person.isNew
          ? ActivityActionEnum.created
          : ActivityActionEnum.updated,
      target: ActivityTargetEnum.person,
      targetId: doc.id,
      label: person.name,
      actor: actor,
    );
    return _store.commit(batch, doc.id);
  }

  @override
  Future<Either<BaseException, String>> delete(
    PersonEntity person, {
    required MemberEntity actor,
  }) async {
    final WriteBatch batch = _store.batch()
      ..delete(_store.doc(StoreCollection.persons, person.id));
    final Either<BaseException, int> drawings = await _cascade.removeFrom(
      batch,
      personId: person.id,
      actor: actor,
    );
    if (drawings.isLeft) return Left(drawings.left);
    final Either<
      BaseException,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
    >
    children = await _store.query(
      _store
          .collection(StoreCollection.persons)
          .where(PersonDocumentMapper.parentId, isEqualTo: person.id),
    );
    if (children.isLeft) return Left(children.left);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> child
        in children.right) {
      batch.update(child.reference, <String, Object?>{
        PersonDocumentMapper.parentId: null,
        PersonDocumentMapper.updated: _store.stamps.write(actor),
      });
    }
    _store.log(
      batch,
      action: ActivityActionEnum.deleted,
      target: ActivityTargetEnum.person,
      targetId: person.id,
      label: person.name,
      actor: actor,
    );
    return _store.commit(batch, person.id);
  }
}
