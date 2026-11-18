import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/map/enum/camera_move_enum.dart';

/// The map's own numbers.
///
/// [minimumCorners] is the fewest distinct corners that enclose an area.
///
/// [home] is where the family's parcels are — a village in Erzurum — and where the
/// map opens before anything is stored; [homeZoom] shows a few village plots
/// at once. Once parcels exist the map opens on them instead.
///
/// [snapPixels] is how close, on screen, a tap must land to an existing corner
/// to be pulled onto it; a fingertip covers about this much.
///
/// [maxZoom] is the deepest the map goes — far past the imagery's own
/// detail, so a corner can be placed to the centimetre on an enlarged tile.
/// [satelliteNativeZoom] and [streetNativeZoom] are the deepest levels the
/// two free imagery sources really have for the family's area; asking for
/// more returns a "map data not yet available" tile, so deeper levels
/// enlarge the last real one instead.
///
/// [overlapToleranceSquareMeters] is how much two drawings may share before
/// the second is refused — enough to forgive a corner placed a hand's width
/// over a neighbour's line, not a strip of someone else's land. Ground
/// within [overlapSliverMeters] of both drawings' sides is not counted at
/// all: along a 30 m side, a hand-drawn line half a metre off the
/// registry's would otherwise add up to many square metres of "overlap"
/// that is only two people drawing the same boundary.
/// [maxPieces] is the most strips one equal split makes, and
/// [pieceSeparator] joins a piece's name to its number or heir ("Tarla – 2")
/// — a merge takes it off again. [coverShare] is
/// how much of an unlinked drawing must lie on a registry parcel for it to
/// count as that parcel's real boundary.
///
/// [cameraMove] decides how the camera shows a place: not at all when it is
/// already wholly in the `visible` box, a slide at the same zoom when part
/// of it is, a move and zoom to fit only when it is off screen — a tap on a
/// parcel in view never jumps the map. Boxes are south-west and north-east
/// corners.
abstract final class MapRules {
  static CameraMoveEnum cameraMove({
    required ({LatLng southWest, LatLng northEast}) visible,
    required List<LatLng> target,
  }) {
    if (target.isEmpty) return CameraMoveEnum.stay;
    bool inside(LatLng p) =>
        p.latitude >= visible.southWest.latitude &&
        p.latitude <= visible.northEast.latitude &&
        p.longitude >= visible.southWest.longitude &&
        p.longitude <= visible.northEast.longitude;
    if (target.every(inside)) return CameraMoveEnum.stay;
    final double south = target.map((LatLng p) => p.latitude).reduce(math.min);
    final double north = target.map((LatLng p) => p.latitude).reduce(math.max);
    final double west = target.map((LatLng p) => p.longitude).reduce(math.min);
    final double east = target.map((LatLng p) => p.longitude).reduce(math.max);
    final bool overlaps =
        south <= visible.northEast.latitude &&
        north >= visible.southWest.latitude &&
        west <= visible.northEast.longitude &&
        east >= visible.southWest.longitude;
    return overlaps ? CameraMoveEnum.pan : CameraMoveEnum.frame;
  }

  static const double overlapToleranceSquareMeters = 2;

  static const double overlapSliverMeters = 0.5;

  static const int maxPieces = 12;

  static const String pieceSeparator = ' – ';

  static const double coverShare = 0.5;

  static const int minimumCorners = 3;

  static const LatLng home = LatLng(40.55905, 41.00095);

  static const double homeZoom = 18;

  static const double snapPixels = 14;

  static const double maxZoom = 24;

  static const int satelliteNativeZoom = 18;

  static const int streetNativeZoom = 19;
}
