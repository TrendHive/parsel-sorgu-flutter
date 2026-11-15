part of 'map_cubit.dart';

/// What the map page is showing.
sealed class MapState {
  const MapState();
}

/// The family's store has not answered yet.
final class MapLoading extends MapState {
  const MapLoading();
}

/// The store could not be read at all.
final class MapFailed extends MapState {
  const MapFailed(this.exception);

  final BaseException exception;
}

/// The map, with everything stored and what the member is doing on it.
///
/// [snapshot] is the family's data; [layers] the drawings switched on;
/// [baseMap] the imagery under them; [member] who is signed in.
///
/// [selection] is what was tapped (its panel is open), or null. [querying]
/// is true while the registry is being asked, so a second tap cannot spend a
/// second lookup.
///
/// [drawing] is the drawing session, or null when not drawing. [focus] asks
/// the page to move the camera — onto a selected record, say — and
/// [focusId] changes each time, so the same place can be asked for twice.
///
/// [split] is a drawing being cut in two, or null. [colourLevel] is the
/// level of the family tree the drawings are coloured by — zero the eldest
/// generation — or null for the plain colours.
///
/// [notice] or [exception] is the last message to show, and [noticeId]
/// changes with each one, so the page shows every message exactly once.
final class MapReady extends MapState {
  const MapReady({
    required this.snapshot,
    required this.layers,
    required this.baseMap,
    required this.member,
    this.selection,
    this.querying = false,
    this.drawing,
    this.split,
    this.colourLevel,
    this.focus,
    this.focusId = CoreConstants.zero,
    this.notice,
    this.exception,
    this.noticeId = CoreConstants.zero,
  });

  final MapSnapshotReadModel snapshot;

  final Set<MapLayerEnum> layers;

  final BaseMapEnum baseMap;

  final MemberEntity? member;

  final MapHitReadModel? selection;

  final bool querying;

  final MapDrawingReadModel? drawing;

  final MapSplitReadModel? split;

  final int? colourLevel;

  final List<LatLng>? focus;

  final int focusId;

  final MapNoticeEnum? notice;

  final BaseException? exception;

  final int noticeId;

  bool get isDrawing => drawing != null;

  MapReady copyWith({
    MapSnapshotReadModel? snapshot,
    Set<MapLayerEnum>? layers,
    BaseMapEnum? baseMap,
    MapHitReadModel? Function()? selection,
    bool? querying,
    MapDrawingReadModel? Function()? drawing,
    MapSplitReadModel? Function()? split,
    int? Function()? colourLevel,
    List<LatLng>? focus,
    MapNoticeEnum? notice,
    BaseException? exception,
  }) => MapReady(
    snapshot: snapshot ?? this.snapshot,
    layers: layers ?? this.layers,
    baseMap: baseMap ?? this.baseMap,
    member: member,
    selection: selection == null ? this.selection : selection(),
    querying: querying ?? this.querying,
    drawing: drawing == null ? this.drawing : drawing(),
    split: split == null ? this.split : split(),
    colourLevel: colourLevel == null ? this.colourLevel : colourLevel(),
    focus: focus ?? this.focus,
    focusId: focus == null ? focusId : focusId + 1,
    notice: notice,
    exception: exception,
    noticeId: notice == null && exception == null ? noticeId : noticeId + 1,
  );
}
