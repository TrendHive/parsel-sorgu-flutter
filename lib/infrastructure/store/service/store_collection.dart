/// The family store's collections, named once.
///
/// [members] holds each account's display name and role; [officialParcels]
/// registry answers keyed by parcel number; [drawnParcels] the family's own
/// boundaries; [persons] and [groups] who holds what; [activity] the
/// append-only change log. `firestore.rules` names the same paths.
enum StoreCollection {
  members('members'),
  officialParcels('officialParcels'),
  drawnParcels('drawnParcels'),
  persons('persons'),
  groups('groups'),
  activity('activity');

  const StoreCollection(this.path);

  final String path;
}
