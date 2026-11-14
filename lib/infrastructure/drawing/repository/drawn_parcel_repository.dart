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
/// activity line. An update keeps `created` and moves `updated`.
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
    );
    return _store.commit(batch, doc.id);
  }

  @override
  Future<Either<BaseException, String>> update(
    DrawnParcelEntity drawing,
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  }) {
    final WriteBatch batch = _store.batch()
      ..update(
        _store.doc(StoreCollection.drawnParcels, drawing.id),
        _mapper.write(outline, details, actor),
      );
    _store.log(
      batch,
      action: ActivityActionEnum.updated,
      target: ActivityTargetEnum.drawnParcel,
      targetId: drawing.id,
      label: details.name,
      actor: actor,
    );
    return _store.commit(batch, drawing.id);
  }

  @override
  Future<Either<BaseException, String>> delete(
    DrawnParcelEntity drawing, {
    required MemberEntity actor,
  }) {
    final WriteBatch batch = _store.batch()
      ..delete(_store.doc(StoreCollection.drawnParcels, drawing.id));
    _store.log(
      batch,
      action: ActivityActionEnum.deleted,
      target: ActivityTargetEnum.drawnParcel,
      targetId: drawing.id,
      label: drawing.name,
      actor: actor,
    );
    return _store.commit(batch, drawing.id);
  }
}
