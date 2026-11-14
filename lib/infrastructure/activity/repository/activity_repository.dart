import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/interface/activity_repository_interface.dart';
import 'package:parcel_atlas/infrastructure/activity/mapper/activity_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// The change log, read newest first.
class ActivityRepository implements ActivityRepositoryInterface {
  ActivityRepository(this._store);

  final FirestoreStoreService _store;

  static const ActivityDocumentMapper _mapper = ActivityDocumentMapper();

  @override
  Stream<Either<BaseException, List<ActivityEntity>>> watchRecent(int limit) =>
      _store.watch(
        _store
            .collection(StoreCollection.activity)
            .orderBy(ActivityDocumentMapper.byAt, descending: true)
            .limit(limit),
        _mapper.read,
      );
}
