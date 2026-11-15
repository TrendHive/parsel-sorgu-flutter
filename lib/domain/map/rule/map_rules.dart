import 'package:latlong2/latlong.dart';

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
/// over a neighbour's line, not a strip of someone else's land.
/// [maxPieces] is the most strips one equal split makes.
abstract final class MapRules {
  static const double overlapToleranceSquareMeters = 2;

  static const int maxPieces = 12;

  static const int minimumCorners = 3;

  static const LatLng home = LatLng(40.55905, 41.00095);

  static const double homeZoom = 18;

  static const double snapPixels = 14;

  static const double maxZoom = 24;

  static const int satelliteNativeZoom = 18;

  static const int streetNativeZoom = 19;
}
