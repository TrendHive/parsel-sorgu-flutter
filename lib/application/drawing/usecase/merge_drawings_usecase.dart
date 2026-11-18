import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/merge_misses_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_merge_read_model.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// Merges neighbouring pieces back into one parcel.
///
/// The first piece takes the joined outline, its name without the split's
/// number, and its note; the others are archived as merged into it. With an
/// `owner` — usually the pieces' common ancestor, such as the father whose
/// land was split among his sons — the parcel becomes wholly theirs; without
/// one, the first piece's owners are kept. Pieces that do not join are
/// refused.
final class MergeDrawingsUseCase {
  const MergeDrawingsUseCase(this._auth, this._drawings);

  final AuthRepositoryInterface _auth;

  final DrawnParcelRepositoryInterface _drawings;

  Future<Either<BaseException, String>> call(
    MapMergeReadModel merge, {
    PersonEntity? owner,
  }) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (!merge.canConfirm) {
      return Left(ValidationException(cause: MergeMissesCause()));
    }
    final GeoPolygonValueObject outline = GeoPolygonValueObject(merge.outline!);
    if (outline.valueObject case Left(:final BaseException value)) {
      return Left(value);
    }
    final DrawnParcelEntity first = merge.first;
    return _drawings.merge(
      first,
      merge.drawings.skip(1).toList(),
      outline,
      DrawingDetailsValueObject((
        name: merge.name,
        officialParcelId: first.officialParcelId,
        owners: owner == null
            ? first.owners
            : <OwnershipValueObject>[
                OwnershipValueObject(
                  personId: owner.id,
                  share: ShareValueObject.whole,
                ),
              ],
        note: first.note,
      )),
      actor: actor,
    );
  }
}
