import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/application/drawing/usecase/delete_drawing_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/save_drawing_usecase.dart';
import 'package:parcel_atlas/application/map/usecase/locate_device_usecase.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_at_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/refresh_parcel_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_drawing_read_model.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_draft_value_object.dart';
import 'package:parcel_atlas/domain/map/enum/base_map_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_layer_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_notice_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';

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
/// lookup ever. [refresh] is the Refresh button.
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
/// [_pendingSelection] holds its id until the snapshot carries it.
final class MapCubit extends Cubit<MapState> {
  MapCubit(
    this._watchMap,
    this._queryAt,
    this._refresh,
    this._saveDrawing,
    this._deleteDrawing,
    this._locate,
    this._auth,
  ) : super(const MapLoading());

  final WatchMapUseCase _watchMap;

  final QueryParcelAtUseCase _queryAt;

  final RefreshParcelUseCase _refresh;

  final SaveDrawingUseCase _saveDrawing;

  final DeleteDrawingUseCase _deleteDrawing;

  final LocateDeviceUseCase _locate;

  final AuthRepositoryInterface _auth;

  StreamSubscription<Either<BaseException, MapSnapshotReadModel>>?
  _subscription;

  DrawingDraftValueObject? _dragOrigin;

  String? _pendingSelection;

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
    return ready.copyWith(
      selection: () => hit,
      focus: drawing?.outline.corners ?? official!.record.outline.corners,
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
    emit(current.copyWith(querying: true));
    _afterRegistry(await _refresh(parcel), MapNoticeEnum.refreshed);
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
    final Either<BaseException, String> result = await _saveDrawing(
      outline: drawing.draft.outline,
      details: details,
      existing: drawing.editing,
    );
    if (isClosed) return;
    final MapState after = state;
    if (after is! MapReady) return;
    switch (result) {
      case Left(:final BaseException value):
        emit(after.copyWith(exception: value));
      case Right(:final String value):
        _pendingSelection = value;
        emit(
          _resolvePending(
            after.copyWith(
              drawing: () => null,
              layers: <MapLayerEnum>{...after.layers, MapLayerEnum.drawn},
              notice: MapNoticeEnum.drawingSaved,
            ),
          ),
        );
    }
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
