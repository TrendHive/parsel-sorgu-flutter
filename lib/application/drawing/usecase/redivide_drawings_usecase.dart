import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/cause/split_misses_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_redivide_read_model.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';

/// Stores a re-division: both neighbours take their new outlines in one
/// batch, keeping their names, owners and notes, so the joined ground is
/// never stored twice or left out.
///
/// A re-division that has no pieces yet is refused. Answers the first
/// drawing's id.
final class RedivideDrawingsUseCase {
  const RedivideDrawingsUseCase(this._auth, this._drawings);

  final AuthRepositoryInterface _auth;

  final DrawnParcelRepositoryInterface _drawings;

  Future<Either<BaseException, String>> call(
    MapRedivideReadModel redivide,
  ) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    final DrawnParcelEntity? second = redivide.second;
    final ({List<LatLng> first, List<LatLng> second})? pieces = redivide.pieces;
    if (!redivide.canConfirm || second == null || pieces == null) {
      return Left(ValidationException(cause: SplitMissesCause()));
    }
    final List<({DrawnParcelEntity drawing, GeoPolygonValueObject outline})>
    changes = <({DrawnParcelEntity drawing, GeoPolygonValueObject outline})>[
      (drawing: redivide.first, outline: GeoPolygonValueObject(pieces.first)),
      (drawing: second, outline: GeoPolygonValueObject(pieces.second)),
    ];
    for (final ({DrawnParcelEntity drawing, GeoPolygonValueObject outline})
        change
        in changes) {
      if (change.outline.valueObject case Left(:final BaseException value)) {
        return Left(value);
      }
    }
    return _drawings.reshape(changes, actor: actor);
  }
}
