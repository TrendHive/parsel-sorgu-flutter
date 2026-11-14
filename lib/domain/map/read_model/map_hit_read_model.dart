import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';

/// What a tap on the map landed on.
///
/// A drawn boundary sits above the registry's, so it wins where both cover
/// the point; [MapHitNone] keeps the point, because a tap on nothing is the
/// question "what parcel is here?" and the answer needs the place.
sealed class MapHitReadModel extends BaseReadModel {
  const MapHitReadModel();
}

/// A tap on a drawn boundary.
final class MapHitDrawn extends MapHitReadModel {
  const MapHitDrawn(this.drawing);

  final DrawnParcelEntity drawing;

  @override
  List<Object?> get props => <Object?>[drawing.id];
}

/// A tap on a registry parcel the family already stored.
final class MapHitOfficial extends MapHitReadModel {
  const MapHitOfficial(this.parcel);

  final OfficialParcelEntity parcel;

  @override
  List<Object?> get props => <Object?>[parcel.id];
}

/// A tap where nothing is stored.
final class MapHitNone extends MapHitReadModel {
  const MapHitNone(this.point);

  final LatLng point;

  @override
  List<Object?> get props => <Object?>[point];
}
