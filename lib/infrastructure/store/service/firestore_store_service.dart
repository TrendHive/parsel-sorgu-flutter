import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_member_cause.dart';
import 'package:parcel_atlas/core/cause/record_missing_cause.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/network_exception.dart';
import 'package:parcel_atlas/core/exception/not_found_exception.dart';
import 'package:parcel_atlas/core/exception/unknown_exception.dart';
import 'package:parcel_atlas/core/logger/local_logger.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The internal source: the family's shared store, in Cloud Firestore.
///
/// Repositories never touch Firestore's API beyond what this offers, so the
/// three things every write must get right are written once here:
///
/// - [watch] streams a collection live from every device and skips a
///   document its mapper cannot read instead of failing the list.
/// - [batch] / [log] / [commit]: a change and its activity line go in one
///   atomic batch, so neither can exist without the other. A line written
///   with a `ref` can be undone: it carries the record's path, what it was
///   just before ([before] reads it; null for a record the change creates)
///   and the change's id ([newChangeId]), shared by every line of one
///   batch, so the whole change is undone together.
/// - [failure] turns Firestore's errors into the app's exceptions: a refused
///   read or write means the account is not on the family's list.
///
/// [stamps] writes who-and-when with the server's clock.
class FirestoreStoreService {
  FirestoreStoreService(this._firestore);

  final FirebaseFirestore _firestore;

  final AuditStampMapper stamps = const AuditStampMapper();

  static const String _action = 'action';
  static const String _target = 'target';
  static const String _targetId = 'targetId';
  static const String _label = 'label';
  static const String _by = 'by';
  static const String changeId = 'changeId';
  static const String path = 'path';
  static const String previous = 'before';
  static const String undo = 'undo';
  static const String _permissionDenied = 'permission-denied';
  static const String _notFound = 'not-found';
  static const String _unavailable = 'unavailable';

  CollectionReference<Map<String, dynamic>> collection(StoreCollection name) =>
      _firestore.collection(name.path);

  DocumentReference<Map<String, dynamic>> doc(
    StoreCollection name, [
    String? id,
  ]) => id == null ? collection(name).doc() : collection(name).doc(id);

  Stream<Either<BaseException, List<T>>> watch<T>(
    Query<Map<String, dynamic>> query,
    T? Function(String id, Map<String, dynamic> data) read,
  ) => query
      .snapshots()
      .map<Either<BaseException, List<T>>>((
        QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
        final List<T> items = <T>[];
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in snapshot.docs) {
          try {
            final T? item = read(doc.id, doc.data());
            if (item != null) items.add(item);
          } catch (e, stackTrace) {
            LocalLogger.error(e, stackTrace: stackTrace);
          }
        }
        return Right(items);
      })
      .handleError(
        (Object error) => Left<BaseException, List<T>>(failure(error)),
      );

  Future<
    Either<BaseException, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  >
  query(Query<Map<String, dynamic>> query) async {
    try {
      return Right((await query.get()).docs);
    } catch (e) {
      return Left(failure(e));
    }
  }

  WriteBatch batch() => _firestore.batch();

  String newChangeId() => collection(StoreCollection.activity).doc().id;

  DocumentReference<Map<String, dynamic>> docAt(String fullPath) =>
      _firestore.doc(fullPath);

  Future<Either<BaseException, Map<String, dynamic>?>> before(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      return Right((await ref.get()).data());
    } catch (e) {
      return Left(failure(e));
    }
  }

  void log(
    WriteBatch batch, {
    required ActivityActionEnum action,
    required ActivityTargetEnum target,
    required String targetId,
    required String label,
    required MemberEntity actor,
    String? change,
    DocumentReference<Map<String, dynamic>>? ref,
    Map<String, dynamic>? was,
    bool isUndo = false,
  }) => batch.set(doc(StoreCollection.activity), <String, Object?>{
    _action: action.name,
    _target: target.name,
    _targetId: targetId,
    _label: label,
    _by: stamps.write(actor),
    if (change != null && ref != null) ...<String, Object?>{
      changeId: change,
      path: ref.path,
      previous: was,
      if (isUndo) undo: true,
    },
  });

  Future<Either<BaseException, String>> commit(
    WriteBatch batch,
    String id,
  ) async {
    try {
      await batch.commit();
      return Right(id);
    } catch (e) {
      return Left(failure(e));
    }
  }

  BaseException failure(Object error) {
    LocalLogger.error(error);
    if (error is FirebaseException) {
      return switch (error.code) {
        _permissionDenied => AuthException(cause: NotMemberCause()),
        _notFound => NotFoundException(cause: RecordMissingCause()),
        _unavailable => NetworkException(cause: UnknownCause(cause: error)),
        _ => UnknownException(cause: UnknownCause(cause: error)),
      };
    }
    return UnknownException(cause: UnknownCause(cause: error));
  }
}
