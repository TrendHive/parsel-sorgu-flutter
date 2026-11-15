import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';

/// A drawing being cut in two on the map.
///
/// [points] are the taps so far — the cut is the straight line through the
/// first two. [pieces] are the two outlines that line makes of [drawing],
/// empty until there are two points or when the line misses the drawing;
/// [canConfirm] is whether there is a cut to store.
final class MapSplitReadModel extends BaseReadModel {
  const MapSplitReadModel({
    required this.drawing,
    this.points = const <LatLng>[],
  });

  final DrawnParcelEntity drawing;

  final List<LatLng> points;

  static const int _cutPoints = 2;

  MapSplitReadModel add(LatLng point) => MapSplitReadModel(
    drawing: drawing,
    points: points.length >= _cutPoints
        ? <LatLng>[point]
        : <LatLng>[...points, point],
  );

  List<List<LatLng>> get pieces => points.length < _cutPoints
      ? const <List<LatLng>>[]
      : GeoRules.splitByLine(
          drawing.outline.corners,
          points.first,
          points.last,
        );

  bool get canConfirm => pieces.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[drawing.id, points];
}
