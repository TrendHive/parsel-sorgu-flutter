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
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The change log, read newest first, and undo.
///
/// [undo] reads the change's lines, then in one transaction reads every
/// record they name and refuses unless each is still exactly as the change
/// left it (`ActivityDocumentMapper.leftAsChanged`) — so an edit made since,
/// by any app version or tool, or an undo already done, is never
/// overwritten, and two undos of the same change cannot both commit. Then
/// it puts each record back as its line remembers it: a record the change
/// created is deleted, one it deleted is created again, one it changed gets
/// its old fields back. `updated` (and `created` on a re-created record) is
/// stamped now, as every write is. Each record gets a new line, marked as
/// an undo and remembering what it was just before — so an undo can itself
/// be undone.
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
    final String undoId = _store.newChangeId();
    return _store.transaction<String>((Transaction tx) async {
      final Map<String, Map<String, dynamic>?> now =
          <String, Map<String, dynamic>?>{};
      for (final MapEntry<String, Map<String, dynamic>> line
          in byPath.entries) {
        final Map<String, dynamic>? current = (await tx.get(
          _store.docAt(line.key),
        )).data();
        if (!ActivityDocumentMapper.leftAsChanged(
          now: current,
          line: line.value,
        )) {
          return Left(ValidationException(cause: ChangeSupersededCause()));
        }
        now[line.key] = current;
      }
      for (final MapEntry<String, Map<String, dynamic>> line
          in byPath.entries) {
        final ActivityEntity? entry = _mapper.read(line.key, line.value);
        if (entry == null) {
          return Left(ValidationException(cause: NothingToUndoCause()));
        }
        final DocumentReference<Map<String, dynamic>> ref = _store.docAt(
          line.key,
        );
        final Object? was = line.value[FirestoreStoreService.previous];
        final ActivityActionEnum action;
        if (was is! Map<String, dynamic>) {
          tx.delete(ref);
          action = ActivityActionEnum.deleted;
        } else if (now[line.key] == null) {
          tx.set(ref, <String, Object?>{
            ...was,
            _created: _store.stamps.write(actor),
            _updated: _store.stamps.write(actor),
          });
          action = ActivityActionEnum.created;
        } else {
          tx.set(ref, <String, Object?>{
            ...was,
            _updated: _store.stamps.write(actor),
          });
          action = ActivityActionEnum.updated;
        }
        tx.set(
          _store.doc(StoreCollection.activity),
          _store.line(
            action: action,
            target: entry.target,
            targetId: entry.targetId,
            label: entry.label,
            actor: actor,
            change: undoId,
            ref: ref,
            was: now[line.key],
            isUndo: true,
          ),
        );
      }
      return Right(undoId);
    });
  }

  Future<
    Either<BaseException, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  >
  _lines(String changeId) => _store.query(
    _store
        .collection(StoreCollection.activity)
        .where(FirestoreStoreService.changeId, isEqualTo: changeId),
  );
}
