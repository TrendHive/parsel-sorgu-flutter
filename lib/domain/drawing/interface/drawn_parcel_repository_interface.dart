import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';

/// The family's shared store of drawn boundaries.
///
/// [create] stores a new drawing and answers its id; [update] replaces an
/// existing one's shape and details; [delete] removes it. [split] replaces
/// one drawing by several pieces at once: the drawing itself becomes the
/// first piece and the others are created beside it, so nothing has to be
/// deleted and no moment exists when the land is stored twice or not at all.
/// [reshape] gives several existing drawings new outlines at once — the
/// line between neighbours moved — writing only their geometry, so details
/// changed meanwhile on another device are kept. [merge] is the reverse of
/// a split: `into` takes the joined outline and the new details, and every
/// drawing in `absorbed` is archived as merged into it — kept, not deleted,
/// so any member may merge and the merge can be undone. Each write stores
/// the measurements computed from the outline beside it and logs one
/// activity line in the same atomic batch.
abstract interface class DrawnParcelRepositoryInterface {
  Stream<Either<BaseException, List<DrawnParcelEntity>>> watchAll();

  Future<Either<BaseException, String>> create(
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> update(
    DrawnParcelEntity drawing,
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> split(
    DrawnParcelEntity drawing,
    List<({GeoPolygonValueObject outline, DrawingDetailsValueObject details})>
    pieces, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> reshape(
    List<({DrawnParcelEntity drawing, GeoPolygonValueObject outline})>
    changes, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> merge(
    DrawnParcelEntity into,
    List<DrawnParcelEntity> absorbed,
    GeoPolygonValueObject outline,
    DrawingDetailsValueObject details, {
    required MemberEntity actor,
  });

  Future<Either<BaseException, String>> delete(
    DrawnParcelEntity drawing, {
    required MemberEntity actor,
  });
}
