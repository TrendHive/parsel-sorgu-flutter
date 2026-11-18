import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/application/activity/usecase/undo_change_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/delete_drawing_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/merge_drawings_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/redivide_drawings_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/save_drawing_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/split_drawing_usecase.dart';
import 'package:parcel_atlas/application/map/usecase/locate_device_usecase.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_at_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_by_number_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/refresh_parcel_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_drawing_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_merge_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_redivide_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_split_read_model.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_draft_value_object.dart';
import 'package:parcel_atlas/domain/map/enum/base_map_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_notice_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/rule/parcel_rules.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

part 'map_state.dart';

/// The map page: the family's live data, what is selected, and a drawing in
/// progress.
///
/// It orchestrates and does not compute — every "which parcel is here",
/// "where does this corner snap", "what is the area" is answered by the
/// domain types it holds.
///
/// Browsing: [tap] selects what was tapped when the store has it — no
/// registry call. A tap on ground nobody has looked up goes straight to the
/// registry ([queryAt]) and the answer is stored, so each parcel costs one
/// lookup ever. [refresh] is the Refresh button, and [queryByNumber] finds a
/// parcel by neighbourhood, block and parcel number.
///
/// The registry refuses browsers, so where it cannot be reached
/// (`registryReachable` false — the website) nothing is sent: a lookup that
/// would need it answers with a notice pointing to the desktop or mobile
/// app, and what is already stored keeps working.
///
/// Ownership: [assignOwner] records a person on a registry parcel in one
/// step — the registry record stays untouched, so a parcel nobody drew gets
/// a new drawing with the registry's outline and that person as its owner.
/// [assignOwnerTo] records the person on an existing real boundary, linking
/// it to its registry parcel when it was not. Neither moves the map, and
/// neither is checked for overlap: the first stores the registry's own
/// outline, which a hand-drawn neighbour may well lie over where the
/// registry is wrong, and the second does not change a shape at all —
/// recording an owner must never be refused over geometry. [setColourLevel]
/// colours the drawings by a level of the family tree. [toggleCompare] puts
/// a parcel on the comparison list or takes it off; [clearCompare] empties
/// it.
///
/// [undoLast] takes back the member's newest saved change — offered on the
/// "saved" message — and says so with [MapNoticeEnum.undone].
///
/// Dividing: [startSplit] opens a cut on a drawing; the next two taps set
/// the line and [confirmSplit] stores the two halves. [splitEqual] cuts a
/// drawing into strips of equal area along the dividing direction the
/// member chose (`bearingDegrees`), one per heir when heirs are given.
/// [startRedivide] begins moving the line between a drawing and its
/// neighbour: the next tap on a drawing picks the neighbour and the new
/// shapes are previewed by their deeds; [confirmRedivide] stores them.
/// [startMerge] begins merging pieces back into one: each tap on a drawing
/// adds it or takes it off, the joined shape is previewed, and
/// [confirmMerge] stores it for the owner chosen (the common ancestor by
/// default), archiving the absorbed pieces.
///
/// Drawing: [startDrawing] opens a session, empty or seeded from a registry
/// parcel's outline (the usual way: copy, then move the corners that are
/// wrong) or from a drawing being edited. Corners snap to stored corners
/// within [MapRules.snapPixels] at the current zoom, so the caller passes the
/// ground size of a pixel with every placement. A drag is one undo step: the
/// draft before the drag is kept in [_dragOrigin] and every update is applied
/// to it, not stacked. [saveDrawing] stores the session and selects the
/// result.
///
/// A saved or queried record arrives back through the live snapshot, so
/// [_pendingSelection] holds its id until the snapshot carries it, and
/// [_framePending] whether the camera moves to it then: an owner assigned
/// to a parcel already on screen selects the result where it is, so the
/// map stays still.
final class MapCubit extends Cubit<MapState> {
  MapCubit(
    this._watchMap,
    this._queryAt,
    this._refresh,
    this._queryByNumber,
    this._saveDrawing,
    this._splitDrawing,
    this._redivideDrawings,
    this._mergeDrawings,
    this._deleteDrawing,
    this._locate,
    this._undoChange,
    this._auth, {
    this._registryReachable = true,
  }) : super(const MapLoading());

  final WatchMapUseCase _watchMap;

  final QueryParcelAtUseCase _queryAt;

  final RefreshParcelUseCase _refresh;

  final QueryParcelByNumberUseCase _queryByNumber;

  final SaveDrawingUseCase _saveDrawing;

  final SplitDrawingUseCase _splitDrawing;

  final RedivideDrawingsUseCase _redivideDrawings;

  final MergeDrawingsUseCase _mergeDrawings;

  final DeleteDrawingUseCase _deleteDrawing;

  final LocateDeviceUseCase _locate;

  final UndoChangeUseCase _undoChange;

  final AuthRepositoryInterface _auth;

  final bool _registryReachable;

  StreamSubscription<Either<BaseException, MapSnapshotReadModel>>?
  _subscription;

  DrawingDraftValueObject? _dragOrigin;

  String? _pendingSelection;

  bool _framePending = true;

  bool _framed = false;

  void start({String? focusId}) {
    _pendingSelection = focusId;
    _subscription = _watchMap().listen(_onSnapshot);
  }

  void _onSnapshot(Either<BaseException, MapSnapshotReadModel> event) {
    final MapState current = state;
    switch (event) {
      case Left(:final BaseException value):
        emit(
          current is MapReady
              ? current.copyWith(exception: value)
              : MapFailed(value),
        );
      case Right(:final MapSnapshotReadModel value):
        final MapReady base = current is MapReady
            ? current.copyWith(snapshot: value)
            : MapReady(
                snapshot: value,
                layers: MapLayerEnum.values.toSet(),
                baseMap: BaseMapEnum.satellite,
                member: _auth.currentMember,
              );
        emit(_resolvePending(_refreshSelection(base)));
        if (!_framed &&
            value.allCorners.isNotEmpty &&
            _pendingSelection == null) {
          _framed = true;
          emit((state as MapReady).copyWith(focus: value.allCorners));
        }
    }
  }

  MapReady _refreshSelection(MapReady ready) {
    final MapHitReadModel? selection = ready.selection;
    return switch (selection) {
      MapHitDrawn(:final DrawnParcelEntity drawing) => ready.copyWith(
        selection: () {
          final DrawnParcelEntity? fresh = ready.snapshot.drawingById(
            drawing.id,
          );
          return fresh == null ? null : MapHitDrawn(fresh);
        },
      ),
      MapHitOfficial(:final OfficialParcelEntity parcel) => ready.copyWith(
        selection: () {
          final OfficialParcelEntity? fresh = ready.snapshot.officialById(
            parcel.id,
          );
          return fresh == null ? null : MapHitOfficial(fresh);
        },
      ),
      MapHitNone() || null => ready,
    };
  }

  MapReady _resolvePending(MapReady ready) {
    final String? id = _pendingSelection;
    if (id == null) return ready;
    final DrawnParcelEntity? drawing = ready.snapshot.drawingById(id);
    final OfficialParcelEntity? official = ready.snapshot.officialById(id);
    final MapHitReadModel? hit = drawing != null
        ? MapHitDrawn(drawing)
        : official != null
        ? MapHitOfficial(official)
        : null;
    if (hit == null) return ready;
    _pendingSelection = null;
    _framed = true;
    final bool frame = _framePending;
    _framePending = true;
    return ready.copyWith(
      selection: () => hit,
      focus: frame
          ? drawing?.outline.corners ?? official!.record.outline.corners
          : null,
    );
  }

  void tap(LatLng point, {required double metersPerPixel}) {
    final MapState current = state;
    if (current is! MapReady || current.querying) return;
    final MapDrawingReadModel? drawing = current.drawing;
    if (drawing != null) {
      if (drawing.crosshair) return;
      _placeCorner(current, drawing, point, metersPerPixel);
      return;
    }
    final MapMergeReadModel? merge = current.merge;
    if (merge != null) {
      final MapHitReadModel hit = current.snapshot.hitAt(point, <MapLayerEnum>{
        MapLayerEnum.drawn,
      });
      if (hit is MapHitDrawn) {
        emit(current.copyWith(merge: () => merge.toggle(hit.drawing)));
      }
      return;
    }
    final MapRedivideReadModel? redivide = current.redivide;
    if (redivide != null) {
      final MapHitReadModel hit = current.snapshot.hitAt(point, <MapLayerEnum>{
        MapLayerEnum.drawn,
      });
      if (hit is MapHitDrawn && hit.drawing.id != redivide.first.id) {
        emit(
          current.copyWith(
            redivide: () => MapRedivideReadModel.between(
              first: redivide.first,
              second: hit.drawing,
              snapshot: current.snapshot,
            ),
          ),
        );
      }
      return;
    }
    final MapSplitReadModel? split = current.split;
    if (split != null) {
      emit(
        current.copyWith(
          split: () => split.add(_snap(current, point, metersPerPixel)),
        ),
      );
      return;
    }
    final MapHitReadModel hit = current.snapshot.hitAt(point, current.layers);
    if (hit is MapHitNone) {
      unawaited(queryAt(point));
      return;
    }
    emit(current.copyWith(selection: () => hit));
  }

  void closeSelection() {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(selection: () => null));
  }

  Future<void> queryAt(LatLng point) async {
    final MapState current = state;
    if (current is! MapReady || current.querying) return;
    final bool stored = current.snapshot.officialAt(point) != null;
    if (!stored && !_registryReachable) {
      emit(current.copyWith(notice: MapNoticeEnum.useApp));
      return;
    }
    emit(current.copyWith(querying: true));
    final Either<BaseException, String> result = await _queryAt(
      point,
      current.snapshot,
    );
    _afterRegistry(
      result,
      stored ? MapNoticeEnum.fromStore : MapNoticeEnum.queried,
    );
  }

  Future<void> refresh(OfficialParcelEntity parcel) async {
    final MapState current = state;
    if (current is! MapReady || current.querying) return;
    if (!_registryReachable) {
      emit(current.copyWith(notice: MapNoticeEnum.useApp));
      return;
    }
    emit(current.copyWith(querying: true));
    _afterRegistry(await _refresh(parcel), MapNoticeEnum.refreshed);
  }

  Future<void> queryByNumber({
    required int neighborhoodId,
    required String block,
    required String parcel,
  }) async {
    final MapState current = state;
    if (current is! MapReady || current.querying) return;
    final String key = ParcelRules.keyOf(
      neighborhoodId: neighborhoodId,
      block: block.trim(),
      parcel: parcel.trim(),
    );
    if (!_registryReachable && current.snapshot.officialById(key) == null) {
      emit(current.copyWith(notice: MapNoticeEnum.useApp));
      return;
    }
    emit(current.copyWith(querying: true));
    _afterRegistry(
      await _queryByNumber(
        neighborhoodId: neighborhoodId,
        block: block,
        parcel: parcel,
        snapshot: current.snapshot,
      ),
      MapNoticeEnum.queried,
    );
  }

  Future<void> assignOwner(
    OfficialParcelEntity parcel,
    PersonEntity person, {
    required String name,
  }) async {
    final MapState current = state;
    if (current is! MapReady) return;
    _afterDrawingWrite(
      await _saveDrawing(
        outline: parcel.record.outline,
        details: DrawingDetailsValueObject((
          name: name,
          officialParcelId: parcel.id,
          owners: <OwnershipValueObject>[
            OwnershipValueObject(
              personId: person.id,
              share: ShareValueObject.whole,
            ),
          ],
          note: CoreConstants.empty,
        )),
      ),
      frame: false,
    );
  }

  Future<void> assignOwnerTo(
    DrawnParcelEntity drawing,
    PersonEntity person, [
    String? officialParcelId,
  ]) async {
    final MapState current = state;
    if (current is! MapReady) return;
    _afterDrawingWrite(
      await _saveDrawing(
        outline: drawing.outline,
        details: DrawingDetailsValueObject((
          name: drawing.name,
          officialParcelId: drawing.officialParcelId ?? officialParcelId,
          owners: <OwnershipValueObject>[
            OwnershipValueObject(
              personId: person.id,
              share: ShareValueObject.whole,
            ),
          ],
          note: drawing.note,
        )),
        existing: drawing,
      ),
      frame: false,
    );
  }

  void toggleCompare(String id) {
    final MapState current = state;
    if (current is! MapReady) return;
    final List<String> ids = <String>[...current.compareIds];
    if (!ids.remove(id)) ids.add(id);
    emit(current.copyWith(compareIds: ids));
  }

  void clearCompare() {
    final MapState current = state;
    if (current is MapReady) {
      emit(current.copyWith(compareIds: const <String>[]));
    }
  }

  void setColourLevel(int? level) {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(colourLevel: () => level));
  }

  void startSplit(DrawnParcelEntity drawing) {
    final MapState current = state;
    if (current is! MapReady) return;
    emit(
      current.copyWith(
        selection: () => null,
        split: () => MapSplitReadModel(drawing: drawing),
        focus: drawing.outline.corners,
      ),
    );
  }

  void startRedivide(DrawnParcelEntity drawing) {
    final MapState current = state;
    if (current is! MapReady) return;
    emit(
      current.copyWith(
        selection: () => null,
        redivide: () => MapRedivideReadModel.start(drawing),
        layers: <MapLayerEnum>{...current.layers, MapLayerEnum.drawn},
      ),
    );
  }

  void cancelRedivide() {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(redivide: () => null));
  }

  Future<void> confirmRedivide() async {
    final MapState current = state;
    if (current is! MapReady) return;
    final MapRedivideReadModel? redivide = current.redivide;
    if (redivide == null || !redivide.canConfirm) return;
    _afterDrawingWrite(await _redivideDrawings(redivide), frame: false);
  }

  void startMerge(DrawnParcelEntity drawing) {
    final MapState current = state;
    if (current is! MapReady) return;
    emit(
      current.copyWith(
        selection: () => null,
        merge: () => MapMergeReadModel.start(drawing),
        layers: <MapLayerEnum>{...current.layers, MapLayerEnum.drawn},
      ),
    );
  }

  void cancelMerge() {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(merge: () => null));
  }

  Future<void> confirmMerge({PersonEntity? owner}) async {
    final MapState current = state;
    if (current is! MapReady) return;
    final MapMergeReadModel? merge = current.merge;
    if (merge == null || !merge.canConfirm) return;
    _afterDrawingWrite(await _mergeDrawings(merge, owner: owner));
  }

  void cancelSplit() {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(split: () => null));
  }

  Future<void> confirmSplit() async {
    final MapState current = state;
    if (current is! MapReady) return;
    final MapSplitReadModel? split = current.split;
    if (split == null || !split.canConfirm) return;
    _afterDrawingWrite(
      await _splitDrawing(drawing: split.drawing, outlines: split.pieces),
    );
  }

  Future<void> undoLast() async {
    final Either<BaseException, String> result = await _undoChange();
    if (isClosed) return;
    final MapState current = state;
    if (current is! MapReady) return;
    emit(switch (result) {
      Left(:final BaseException value) => current.copyWith(exception: value),
      Right() => current.copyWith(
        selection: () => null,
        notice: MapNoticeEnum.undone,
      ),
    });
  }

  Future<void> splitEqual(
    DrawnParcelEntity drawing, {
    required int pieces,
    required double bearingDegrees,
    List<PersonEntity>? heirs,
  }) async => _afterDrawingWrite(
    await _splitDrawing(
      drawing: drawing,
      outlines: GeoRules.splitEqual(
        drawing.outline.corners,
        pieces,
        bearingDegrees: bearingDegrees,
      ),
      heirs: heirs,
    ),
  );

  void _afterDrawingWrite(
    Either<BaseException, String> result, {
    bool frame = true,
  }) {
    if (isClosed) return;
    final MapState after = state;
    if (after is! MapReady) return;
    switch (result) {
      case Left(:final BaseException value):
        emit(after.copyWith(exception: value));
      case Right(:final String value):
        _pendingSelection = value;
        _framePending = frame;
        emit(
          _resolvePending(
            after.copyWith(
              drawing: () => null,
              split: () => null,
              redivide: () => null,
              merge: () => null,
              layers: <MapLayerEnum>{...after.layers, MapLayerEnum.drawn},
              notice: MapNoticeEnum.drawingSaved,
            ),
          ),
        );
    }
  }

  void _afterRegistry(
    Either<BaseException, String> result,
    MapNoticeEnum notice,
  ) {
    if (isClosed) return;
    final MapState current = state;
    if (current is! MapReady) return;
    switch (result) {
      case Left(:final BaseException value):
        emit(current.copyWith(querying: false, exception: value));
      case Right(:final String value):
        _pendingSelection = value;
        _framePending = true;
        emit(
          _resolvePending(current.copyWith(querying: false, notice: notice)),
        );
    }
  }

  void toggleLayer(MapLayerEnum layer) {
    final MapState current = state;
    if (current is! MapReady) return;
    final Set<MapLayerEnum> layers = <MapLayerEnum>{...current.layers};
    if (!layers.remove(layer)) layers.add(layer);
    emit(current.copyWith(layers: layers));
  }

  void setBaseMap(BaseMapEnum baseMap) {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(baseMap: baseMap));
  }

  void focusOn(String id) {
    _pendingSelection = id;
    _framePending = true;
    final MapState current = state;
    if (current is MapReady) emit(_resolvePending(current));
  }

  void startDrawing({OfficialParcelEntity? copyFrom, DrawnParcelEntity? edit}) {
    final MapState current = state;
    if (current is! MapReady) return;
    final DrawingDraftValueObject draft = edit != null
        ? DrawingDraftValueObject.startFrom(edit.outline)
        : copyFrom != null
        ? DrawingDraftValueObject.startFrom(copyFrom.record.outline)
        : DrawingDraftValueObject.empty;
    final OfficialParcelEntity? source =
        copyFrom ?? current.snapshot.officialById(edit?.officialParcelId);
    emit(
      current.copyWith(
        selection: () => null,
        layers: <MapLayerEnum>{...current.layers, MapLayerEnum.official},
        drawing: () =>
            MapDrawingReadModel(draft: draft, editing: edit, source: source),
        focus: draft.corners.isEmpty ? null : draft.corners,
      ),
    );
  }

  void cancelDrawing() {
    final MapState current = state;
    if (current is MapReady) emit(current.copyWith(drawing: () => null));
  }

  void setCrosshair({required bool on}) =>
      _updateDrawing((MapDrawingReadModel d) => d.withCrosshair(on: on));

  void placeAtCrosshair(LatLng centre, {required double metersPerPixel}) {
    final MapState current = state;
    if (current is! MapReady) return;
    final MapDrawingReadModel? drawing = current.drawing;
    if (drawing == null) return;
    _placeCorner(current, drawing, centre, metersPerPixel);
  }

  void _placeCorner(
    MapReady current,
    MapDrawingReadModel drawing,
    LatLng point,
    double metersPerPixel,
  ) {
    final LatLng corner = _snap(current, point, metersPerPixel);
    emit(
      current.copyWith(
        drawing: () => drawing.withDraft(drawing.draft.add(corner)),
      ),
    );
  }

  void selectCorner(int? index) => _updateDraft(
    (DrawingDraftValueObject draft) =>
        draft.select(draft.selected == index ? null : index),
  );

  void dragStart(int index) {
    final MapState current = state;
    if (current is MapReady) _dragOrigin = current.drawing?.draft;
  }

  void dragUpdate(int index, LatLng point, {required double metersPerPixel}) {
    final MapState current = state;
    final DrawingDraftValueObject? origin = _dragOrigin;
    if (current is! MapReady || origin == null) return;
    final LatLng corner = _snap(current, point, metersPerPixel);
    _updateDraft((_) => origin.move(index, corner));
  }

  void dragEnd() => _dragOrigin = null;

  void insertCorner(int afterIndex, LatLng point) => _updateDraft(
    (DrawingDraftValueObject draft) => draft.insertAfter(afterIndex, point),
  );

  void removeSelectedCorner() =>
      _updateDraft((DrawingDraftValueObject draft) => draft.removeSelected());

  void undo() => _updateDraft((DrawingDraftValueObject draft) => draft.undo());

  void redo() => _updateDraft((DrawingDraftValueObject draft) => draft.redo());

  Future<void> saveDrawing(DrawingDetailsValueObject details) async {
    final MapState current = state;
    if (current is! MapReady) return;
    final MapDrawingReadModel? drawing = current.drawing;
    if (drawing == null) return;
    _afterDrawingWrite(
      await _saveDrawing(
        outline: drawing.draft.outline,
        details: details,
        existing: drawing.editing,
        snapshot: current.snapshot,
      ),
    );
  }

  Future<void> saveDetails(
    DrawnParcelEntity drawing,
    DrawingDetailsValueObject details,
  ) async {
    final Either<BaseException, String> result = await _saveDrawing(
      outline: drawing.outline,
      details: details,
      existing: drawing,
    );
    if (isClosed) return;
    final MapState current = state;
    if (current is! MapReady) return;
    emit(switch (result) {
      Left(:final BaseException value) => current.copyWith(exception: value),
      Right() => current.copyWith(notice: MapNoticeEnum.drawingSaved),
    });
  }

  Future<void> locate() async {
    final Either<BaseException, LatLng> result = await _locate();
    if (isClosed) return;
    final MapState current = state;
    if (current is! MapReady) return;
    emit(switch (result) {
      Left(:final BaseException value) => current.copyWith(exception: value),
      Right(:final LatLng value) => current.copyWith(focus: <LatLng>[value]),
    });
  }

  Future<void> deleteDrawing(DrawnParcelEntity drawing) async {
    final Either<BaseException, String> result = await _deleteDrawing(drawing);
    if (isClosed) return;
    final MapState current = state;
    if (current is! MapReady) return;
    switch (result) {
      case Left(:final BaseException value):
        emit(current.copyWith(exception: value));
      case Right():
        emit(
          current.copyWith(
            selection: () => null,
            notice: MapNoticeEnum.drawingDeleted,
          ),
        );
    }
  }

  LatLng _snap(MapReady current, LatLng point, double metersPerPixel) =>
      current.snapshot.snapTo(
        point,
        toleranceMeters: MapRules.snapPixels * metersPerPixel,
      ) ??
      point;

  void _updateDraft(
    DrawingDraftValueObject Function(DrawingDraftValueObject) change,
  ) => _updateDrawing(
    (MapDrawingReadModel drawing) => drawing.withDraft(change(drawing.draft)),
  );

  void _updateDrawing(
    MapDrawingReadModel Function(MapDrawingReadModel) change,
  ) {
    final MapState current = state;
    if (current is! MapReady) return;
    final MapDrawingReadModel? drawing = current.drawing;
    if (drawing == null) return;
    emit(current.copyWith(drawing: () => change(drawing)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
