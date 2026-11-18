import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/change_superseded_cause.dart';
import 'package:parcel_atlas/core/cause/nothing_to_undo_cause.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/interface/activity_repository_interface.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/infrastructure/activity/mapper/activity_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The change log, read newest first, and undo.
///
/// [undo] reads the change's lines, refuses when a later line names any of
/// the same records (they were changed again, or the change was already
/// undone), then in one batch puts each record back as its line remembers
/// it: a record the change created is deleted, one it deleted is created
/// again, one it changed gets its old fields back. `updated` (and `created`
/// on a re-created record) is stamped now, as every write is. Each record
/// gets a new line, marked as an undo and remembering what it was just
/// before — so an undo can itself be undone.
///
/// [latestChangeBy] looks through the newest [recentWindow] lines only.
class ActivityRepository implements ActivityRepositoryInterface {
  ActivityRepository(this._store);

  final FirestoreStoreService _store;

  static const ActivityDocumentMapper _mapper = ActivityDocumentMapper();

  static const int recentWindow = 50;

  static const String _created = 'created';
  static const String _updated = 'updated';

  @override
  Stream<Either<BaseException, List<ActivityEntity>>> watchRecent(int limit) =>
      _store.watch(
        _store
            .collection(StoreCollection.activity)
            .orderBy(ActivityDocumentMapper.byAt, descending: true)
            .limit(limit),
        _mapper.read,
      );

  @override
  Future<Either<BaseException, List<ActivityEntity>>> linesOf(
    String changeId,
  ) async => (await _lines(changeId)).map(
    (List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) => docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              _mapper.read(doc.id, doc.data()),
        )
        .nonNulls
        .toList(),
  );

  @override
  Future<Either<BaseException, String?>> latestChangeBy(
    String memberId,
  ) async =>
      (await _store.query(
        _store
            .collection(StoreCollection.activity)
            .orderBy(ActivityDocumentMapper.byAt, descending: true)
            .limit(recentWindow),
      )).map(
        (List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) => docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  _mapper.read(doc.id, doc.data()),
            )
            .nonNulls
            .where(
              (ActivityEntity line) =>
                  line.canUndo && line.stamp.memberId == memberId,
            )
            .firstOrNull
            ?.changeId,
      );

  @override
  Future<Either<BaseException, String>> undo(
    String changeId, {
    required MemberEntity actor,
  }) async {
    final Either<
      BaseException,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
    >
    found = await _lines(changeId);
    if (found.isLeft) return Left(found.left);
    final Map<String, Map<String, dynamic>> byPath =
        <String, Map<String, dynamic>>{};
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in found.right) {
      final Object? path = doc.data()[FirestoreStoreService.path];
      if (path is! String) {
        return Left(ValidationException(cause: NothingToUndoCause()));
      }
      byPath.putIfAbsent(path, doc.data);
    }
    if (byPath.isEmpty) {
      return Left(ValidationException(cause: NothingToUndoCause()));
    }
    final Timestamp? at = _at(found.right.first.data());
    for (final String path in byPath.keys) {
      final Either<
        BaseException,
        List<QueryDocumentSnapshot<Map<String, dynamic>>>
      >
      touching = await _store.query(
        _store
            .collection(StoreCollection.activity)
            .where(FirestoreStoreService.path, isEqualTo: path),
      );
      if (touching.isLeft) return Left(touching.left);
      final bool changedSince = touching.right.any(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            doc.data()[FirestoreStoreService.changeId] != changeId &&
            _isAfter(_at(doc.data()), at),
      );
      if (changedSince) {
        return Left(ValidationException(cause: ChangeSupersededCause()));
      }
    }
    final String undoId = _store.newChangeId();
    final WriteBatch batch = _store.batch();
    for (final MapEntry<String, Map<String, dynamic>> line in byPath.entries) {
      final ActivityEntity? entry = _mapper.read(line.key, line.value);
      if (entry == null) {
        return Left(ValidationException(cause: NothingToUndoCause()));
      }
      final DocumentReference<Map<String, dynamic>> ref = _store.docAt(
        line.key,
      );
      final Either<BaseException, Map<String, dynamic>?> now = await _store
          .before(ref);
      if (now.isLeft) return Left(now.left);
      final Object? was = line.value[FirestoreStoreService.previous];
      final ActivityActionEnum action;
      if (was is! Map<String, dynamic>) {
        batch.delete(ref);
        action = ActivityActionEnum.deleted;
      } else if (now.right == null) {
        batch.set(ref, <String, Object?>{
          ...was,
          _created: _store.stamps.write(actor),
          _updated: _store.stamps.write(actor),
        });
        action = ActivityActionEnum.created;
      } else {
        batch.set(ref, <String, Object?>{
          ...was,
          _updated: _store.stamps.write(actor),
        });
        action = ActivityActionEnum.updated;
      }
      _store.log(
        batch,
        action: action,
        target: entry.target,
        targetId: entry.targetId,
        label: entry.label,
        actor: actor,
        change: undoId,
        ref: ref,
        was: now.right,
        isUndo: true,
      );
    }
    return _store.commit(batch, undoId);
  }

  Future<
    Either<BaseException, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  >
  _lines(String changeId) => _store.query(
    _store
        .collection(StoreCollection.activity)
        .where(FirestoreStoreService.changeId, isEqualTo: changeId),
  );

  static Timestamp? _at(Map<String, dynamic> line) {
    final Object? by = line[ActivityDocumentMapper.by];
    final Object? at = by is Map<String, dynamic>
        ? by[AuditStampMapper.at]
        : null;
    return at is Timestamp ? at : null;
  }

  static bool _isAfter(Timestamp? candidate, Timestamp? reference) =>
      candidate == null ||
      reference == null ||
      candidate.compareTo(reference) > 0;
}
