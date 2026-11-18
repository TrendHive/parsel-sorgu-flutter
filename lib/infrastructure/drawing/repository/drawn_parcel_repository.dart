import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/infrastructure/drawing/mapper/drawn_parcel_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The family's drawn boundaries in the store.
///
/// Every write is one batch: the drawing (with its measurements) and its
/// activity line, which records what the drawing was before so the change
/// can be undone. An update keeps `created` and moves `updated`.
class DrawnParcelRepository implements DrawnParcelRepositoryInterface {
  DrawnParcelRepository(this._store);

  final FirestoreStoreService _store;

  static const DrawnParcelDocumentMapper _mapper = DrawnParcelDocumentMapper();

  @override
  Stream<Either<BaseException, List<DrawnParcelEntity>>> watchAll() => _store
      .watch(_store.collection(StoreCollection.drawnParcels), _mapper.read);

  @override
  Future<Either<BaseException, String>> create(
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  }) {
    final DocumentReference<Map<String, dynamic>> doc = _store.doc(
      StoreCollection.drawnParcels,
    );
    final WriteBatch batch = _store.batch()
      ..set(doc, <String, Object?>{
        ..._mapper.write(outline, details, actor),
        DrawnParcelDocumentMapper.created: _store.stamps.write(actor),
      });
    _store.log(
      batch,
      action: ActivityActionEnum.created,
      target: ActivityTargetEnum.drawnParcel,
      targetId: doc.id,
      label: details.name,
      actor: actor,
      change: _store.newChangeId(),
      ref: doc,
    );
    return _store.commit(batch, doc.id);
  }

  @override
  Future<Either<BaseException, String>> update(
    DrawnParcelEntity drawing,
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc = _store.doc(
      StoreCollection.drawnParcels,
      drawing.id,
    );
    final Either<BaseException, Map<String, dynamic>?> was = await _store
        .before(doc);
    if (was.isLeft) return Left(was.left);
    final WriteBatch batch = _store.batch()
      ..update(doc, _mapper.write(outline, details, actor));
    _store.log(
      batch,
      action: ActivityActionEnum.updated,
      target: ActivityTargetEnum.drawnParcel,
      targetId: drawing.id,
      label: details.name,
      actor: actor,
      change: _store.newChangeId(),
      ref: doc,
      was: was.right,
    );
    return _store.commit(batch, drawing.id);
  }

  @override
  Future<Either<BaseException, String>> split(
    DrawnParcelEntity drawing,
    List<({GeoPolygonValueObject outline, DrawingDetailsValueObject details})>
    pieces, {
    required MemberEntity actor,
  }) async {
    final Either<BaseException, Map<String, dynamic>?> was = await _store
        .before(_store.doc(StoreCollection.drawnParcels, drawing.id));
    if (was.isLeft) return Left(was.left);
    final String change = _store.newChangeId();
    final WriteBatch batch = _store.batch();
    for (final (
          int index,
          ({GeoPolygonValueObject outline, DrawingDetailsValueObject details})
          piece,
        )
        in pieces.indexed) {
      final bool first = index == 0;
      final DocumentReference<Map<String, dynamic>> doc = first
          ? _store.doc(StoreCollection.drawnParcels, drawing.id)
          : _store.doc(StoreCollection.drawnParcels);
      final Map<String, Object?> data = _mapper.write(
        piece.outline,
        piece.details,
        actor,
      );
      if (first) {
        batch.update(doc, data);
      } else {
        batch.set(doc, <String, Object?>{
          ...data,
          DrawnParcelDocumentMapper.created: _store.stamps.write(actor),
        });
      }
      _store.log(
        batch,
        action: first ? ActivityActionEnum.updated : ActivityActionEnum.created,
        target: ActivityTargetEnum.drawnParcel,
        targetId: doc.id,
        label: piece.details.name,
        actor: actor,
        change: change,
        ref: doc,
        was: first ? was.right : null,
      );
    }
    return _store.commit(batch, drawing.id);
  }

  @override
  Future<Either<BaseException, String>> reshape(
    List<({DrawnParcelEntity drawing, GeoPolygonValueObject outline})>
    changes, {
    required MemberEntity actor,
  }) async {
    final String changeId = _store.newChangeId();
    final WriteBatch batch = _store.batch();
    for (final ({DrawnParcelEntity drawing, GeoPolygonValueObject outline})
        change
        in changes) {
      final DrawnParcelEntity drawing = change.drawing;
      final DocumentReference<Map<String, dynamic>> doc = _store.doc(
        StoreCollection.drawnParcels,
        drawing.id,
      );
      final Either<BaseException, Map<String, dynamic>?> was = await _store
          .before(doc);
      if (was.isLeft) return Left(was.left);
      batch.update(doc, _mapper.writeShape(change.outline, actor));
      _store.log(
        batch,
        action: ActivityActionEnum.updated,
        target: ActivityTargetEnum.drawnParcel,
        targetId: drawing.id,
        label: drawing.name,
        actor: actor,
        change: changeId,
        ref: doc,
        was: was.right,
      );
    }
    return _store.commit(batch, changes.first.drawing.id);
  }

  @override
  Future<Either<BaseException, String>> merge(
    DrawnParcelEntity into,
    List<DrawnParcelEntity> absorbed,
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  }) async {
    final String change = _store.newChangeId();
    final WriteBatch batch = _store.batch();
    for (final DrawnParcelEntity drawing in <DrawnParcelEntity>[
      into,
      ...absorbed,
    ]) {
      final bool first = drawing.id == into.id;
      final DocumentReference<Map<String, dynamic>> doc = _store.doc(
        StoreCollection.drawnParcels,
        drawing.id,
      );
      final Either<BaseException, Map<String, dynamic>?> was = await _store
          .before(doc);
      if (was.isLeft) return Left(was.left);
      batch.update(
        doc,
        first
            ? _mapper.write(outline, details, actor)
            : <String, Object?>{
                DrawnParcelDocumentMapper.mergedInto: into.id,
                DrawnParcelDocumentMapper.updated: _store.stamps.write(actor),
              },
      );
      _store.log(
        batch,
        action: ActivityActionEnum.updated,
        target: ActivityTargetEnum.drawnParcel,
        targetId: drawing.id,
        label: first ? details.name : drawing.name,
        actor: actor,
        change: change,
        ref: doc,
        was: was.right,
      );
    }
    return _store.commit(batch, into.id);
  }

  @override
  Future<Either<BaseException, String>> delete(
    DrawnParcelEntity drawing, {
    required MemberEntity actor,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc = _store.doc(
      StoreCollection.drawnParcels,
      drawing.id,
    );
    final Either<BaseException, Map<String, dynamic>?> was = await _store
        .before(doc);
    if (was.isLeft) return Left(was.left);
    final WriteBatch batch = _store.batch()..delete(doc);
    _store.log(
      batch,
      action: ActivityActionEnum.deleted,
      target: ActivityTargetEnum.drawnParcel,
      targetId: drawing.id,
      label: drawing.name,
      actor: actor,
      change: _store.newChangeId(),
      ref: doc,
      was: was.right,
    );
    return _store.commit(batch, drawing.id);
  }
}
