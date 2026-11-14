import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';

/// Stores a drawn boundary: a new one when `existing` is null, otherwise a
/// change to that one — its shape, name, linked parcel, people or note.
///
/// The outline must enclose an area and the drawing must have a name; both
/// are checked before anything is written. Answers the drawing's id.
final class SaveDrawingUseCase {
  const SaveDrawingUseCase(this._auth, this._drawings);

  final AuthRepositoryInterface _auth;

  final DrawnParcelRepositoryInterface _drawings;

  Future<Either<BaseException, String>> call({
    required GeoPolygonValueObject outline,
    required DrawingDetailsValueObject details,
    DrawnParcelEntity? existing,
  }) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (outline.valueObject case Left(:final BaseException value)) {
      return Left(value);
    }
    if (details.valueObject case Left(:final BaseException value)) {
      return Left(value);
    }
    return existing == null
        ? _drawings.create(outline, details, actor: actor)
        : _drawings.update(existing, outline, details, actor: actor);
  }
}
