import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/cause/split_misses_cause.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// Replaces one drawing by the pieces it was cut into.
///
/// Without `heirs` every piece keeps the drawing's owners and note and is
/// named after it with a number ("Tarla – 2"). With `heirs` — one per piece,
/// in order — each piece is named after its heir and becomes wholly theirs:
/// the land is divided, so nobody shares a piece any more.
///
/// Fewer than two pieces is no split and is refused. Answers the id of the
/// first piece, which is the original drawing.
final class SplitDrawingUseCase {
  const SplitDrawingUseCase(this._auth, this._drawings);

  final AuthRepositoryInterface _auth;

  final DrawnParcelRepositoryInterface _drawings;

  Future<Either<BaseException, String>> call({
    required DrawnParcelEntity drawing,
    required List<List<LatLng>> outlines,
    List<PersonEntity>? heirs,
  }) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (outlines.length < CoreConstants.two ||
        (heirs != null && heirs.length != outlines.length)) {
      return Left(ValidationException(cause: SplitMissesCause()));
    }
    final List<
      ({GeoPolygonValueObject outline, DrawingDetailsValueObject details})
    >
    pieces =
        <({GeoPolygonValueObject outline, DrawingDetailsValueObject details})>[
          for (final (int index, List<LatLng> corners) in outlines.indexed)
            (
              outline: GeoPolygonValueObject(corners),
              details: DrawingDetailsValueObject((
                name: <String>[
                  drawing.name,
                  heirs?[index].name ?? '${index + CoreConstants.one}',
                ].join(_separator),
                officialParcelId: drawing.officialParcelId,
                owners: heirs == null
                    ? drawing.owners
                    : <OwnershipValueObject>[
                        OwnershipValueObject(
                          personId: heirs[index].id,
                          share: ShareValueObject.whole,
                        ),
                      ],
                note: drawing.note,
              )),
            ),
        ];
    for (final ({
          GeoPolygonValueObject outline,
          DrawingDetailsValueObject details,
        })
        piece
        in pieces) {
      if (piece.outline.valueObject case Left(:final BaseException value)) {
        return Left(value);
      }
    }
    return _drawings.split(drawing, pieces, actor: actor);
  }

  static const String _separator = ' – ';
}
