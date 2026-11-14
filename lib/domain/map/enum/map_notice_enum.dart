/// A short confirmation the map shows after something worked.
///
/// [fromStore] tells a member the parcel came from the family's store — no
/// registry lookup was spent. [queried] and [refreshed] are registry answers
/// saved; [drawingSaved] and [drawingDeleted] are drawings.
enum MapNoticeEnum {
  fromStore,
  queried,
  refreshed,
  drawingSaved,
  drawingDeleted,
}
