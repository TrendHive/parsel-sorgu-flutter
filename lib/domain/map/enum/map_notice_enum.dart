/// A short confirmation the map shows after something worked.
///
/// [fromStore] tells a member the parcel came from the family's store — no
/// registry lookup was spent. [queried] and [refreshed] are registry answers
/// saved; [drawingSaved] and [drawingDeleted] are drawings. [useApp] sends
/// a member on the website to the desktop or mobile app for a registry
/// lookup, which the registry refuses from a browser. [undone] is a saved
/// change taken back.
enum MapNoticeEnum {
  fromStore,
  queried,
  refreshed,
  drawingSaved,
  drawingDeleted,
  useApp,
  undone,
}
