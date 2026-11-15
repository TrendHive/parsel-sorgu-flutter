import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/domain/activity/value_object/audit_stamp_value_object.dart';
import 'package:parcel_atlas/domain/map/value_object/geo_polygon_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// A boundary the family drew where the registry's is wrong.
///
/// [outline] is the drawn shape; its area and sides are computed from it, so
/// they are exact for what was drawn. [officialParcelId] is the registry
/// parcel it corrects, when there is one — the registry record itself is
/// never changed. [owners] and [note] live here and only here: a drawn
/// boundary is the family's record of what is really theirs, so it is what
/// people hold shares of.
///
/// [allocated] is the sum of all shares; [isFullyAllocated] whether it is
/// exactly the whole parcel.
final class DrawnParcelEntity extends BaseEntity {
  const DrawnParcelEntity({
    required this.id,
    required this.name,
    required this.outline,
    required this.officialParcelId,
    required this.owners,
    required this.note,
    required this.created,
    required this.updated,
  });

  @override
  final String id;

  final String name;

  final GeoPolygonValueObject outline;

  final String? officialParcelId;

  final List<OwnershipValueObject> owners;

  final String note;

  final AuditStampValueObject created;

  final AuditStampValueObject updated;

  ShareValueObject get allocated => owners.fold(
    ShareValueObject.none,
    (ShareValueObject sum, OwnershipValueObject line) => sum.plus(line.share),
  );

  bool get isFullyAllocated => allocated.isWhole;
}
