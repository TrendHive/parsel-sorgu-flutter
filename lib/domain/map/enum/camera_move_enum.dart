/// How the map's camera answers a request to show a place.
///
/// [stay]: it is already wholly on screen, so nothing moves. [pan]: part of
/// it is on screen, so the map slides to centre it at the same zoom.
/// [frame]: it is off screen, so the map moves and zooms to fit it.
enum CameraMoveEnum { stay, pan, frame }
