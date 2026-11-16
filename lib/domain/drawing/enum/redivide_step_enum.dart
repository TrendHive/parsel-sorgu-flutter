/// Where a re-division stands, so the bar over the map can say so.
///
/// [pickNeighbour]: waiting for a tap on the neighbouring real boundary.
/// [noDeed]: one of the two has no registry parcel, so there is no deed
/// area to divide by. [sameDeed]: both belong to the same registry parcel,
/// whose deed says nothing about how it is split. [splitDeed]: one of the
/// deeds is already divided among several real boundaries, so its whole area
/// is not this drawing's to claim. [notNeighbours]: they do
/// not share a side. [ready]: the new shapes are shown and can be stored.
enum RedivideStepEnum {
  pickNeighbour,
  noDeed,
  sameDeed,
  splitDeed,
  notNeighbours,
  ready,
}
