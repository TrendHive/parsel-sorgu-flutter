import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/auth/cubit/session_cubit.dart';
import 'package:parcel_atlas/application/map/cubit/map_cubit.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_drawing_read_model.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/enum/map_notice_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/domain_ui/dialog/confirm/confirm_dialog.dart';
import 'package:parcel_atlas/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/values/window_size_class_enum.dart';
import 'package:parcel_atlas/domain_ui/widgets/feedback/parcel_info_toast.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/dialog/save_drawing_dialog.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_attribution.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_drawing_layer.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_drawing_toolbar.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_drawn_panel.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_official_panel.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_parcel_layers.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_tile_layer.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_top_bar.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// The map and everything over it.
///
/// It owns the [MapController] and turns the screen into the Cubit's terms:
/// every tap, drag and crosshair placement goes in with the ground size of a
/// pixel at the current zoom, which is what lets corners snap the same
/// distance on screen whatever the zoom. It shows each message once
/// (`noticeId`) and moves the camera when asked (`focusId`).
///
/// Layout follows the window size class, never the device: the selected
/// record's panel rises from the bottom in a compact or medium window and
/// sits at the right from expanded up.
///
/// While drawing, the keyboard is an accelerator beside the buttons:
/// Ctrl/Cmd+Z undoes, Ctrl/Cmd+Shift+Z or Ctrl+Y redoes, Delete or
/// Backspace removes the selected corner, Escape discards the drawing.
class MapBody extends StatefulWidget {
  const MapBody({super.key});

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  final MapController _controller = MapController();

  static const double _focusZoom = 19;
  static const double _fitMaxZoom = 20;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _metersPerPixel => GeoRules.metersPerPixel(
    latitudeDegrees: _controller.camera.center.latitude,
    zoom: _controller.camera.zoom,
  );

  MapCubit get _cubit => context.read<MapCubit>();

  void _listen(BuildContext context, MapState state) {
    if (state is! MapReady) {
      if (state is MapFailed) {
        ParcelInfoToast.show(
          context,
          ExceptionCopy.of(ParcelInfoLocalKeys.of(context), state.exception),
          isError: true,
        );
      }
      return;
    }
    _showMessage(context, state);
  }

  void _showMessage(BuildContext context, MapReady state) {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    if (state.exception != null) {
      ParcelInfoToast.show(
        context,
        ExceptionCopy.of(l10n, state.exception!),
        isError: true,
      );
    } else if (state.notice != null) {
      ParcelInfoToast.show(context, switch (state.notice!) {
        MapNoticeEnum.fromStore => l10n.noticeFromStore,
        MapNoticeEnum.queried => l10n.noticeQueried,
        MapNoticeEnum.refreshed => l10n.noticeRefreshed,
        MapNoticeEnum.drawingSaved => l10n.noticeDrawingSaved,
        MapNoticeEnum.drawingDeleted => l10n.noticeDrawingDeleted,
      });
    }
  }

  void _focus(List<LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == CoreConstants.one) {
      _controller.move(points.single, _focusZoom);
      return;
    }
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: EdgeInsets.all(BaseDimens.padding.xxxxxLarge),
        maxZoom: _fitMaxZoom,
      ),
    );
  }

  Future<void> _finishDrawing(
    MapReady state,
    MapDrawingReadModel drawing,
  ) async {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    final DrawnParcelEntity? editing = drawing.editing;
    final DrawingDetailsValueObject? details = await SaveDrawingDialog.open(
      context,
      snapshot: state.snapshot,
      name:
          editing?.name ??
          (drawing.source == null
              ? CoreConstants.empty
              : l10n.drawingNameDefault(drawing.source!.label)),
      owners: editing?.owners ?? const <OwnershipValueObject>[],
      note: editing?.note ?? CoreConstants.empty,
      officialParcelId: editing?.officialParcelId ?? drawing.source?.id,
    );
    if (details != null) await _cubit.saveDrawing(details);
  }

  Future<void> _editDetails(MapReady state, DrawnParcelEntity drawing) async {
    final DrawingDetailsValueObject? details = await SaveDrawingDialog.open(
      context,
      snapshot: state.snapshot,
      name: drawing.name,
      owners: drawing.owners,
      note: drawing.note,
      officialParcelId: drawing.officialParcelId,
    );
    if (details != null) await _cubit.saveDetails(drawing, details);
  }

  Future<void> _delete(DrawnParcelEntity drawing) async {
    if (await ConfirmDialog.ask(context, name: drawing.name)) {
      await _cubit.deleteDrawing(drawing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listenWhen: (MapState previous, MapState next) =>
          next is! MapReady ||
          previous is! MapReady ||
          previous.noticeId != next.noticeId ||
          previous.focusId != next.focusId,
      listener: (BuildContext context, MapState state) {
        _listen(context, state);
        if (state is MapReady && state.focus != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _focus(state.focus!),
          );
        }
      },
      builder: (BuildContext context, MapState state) {
        final MapReady? ready = state is MapReady ? state : null;
        final WindowSizeClassEnum size = WindowSizeClassEnum.of(
          MediaQuery.sizeOf(context).width,
        );
        final bool wide = size.isAtLeast(WindowSizeClassEnum.expanded);
        final Widget map = Stack(
          children: <Widget>[
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: MapRules.home,
                initialZoom: MapRules.homeZoom,
                maxZoom: MapRules.maxZoom,
                onTap: (_, LatLng point) =>
                    _cubit.tap(point, metersPerPixel: _metersPerPixel),
              ),
              children: <Widget>[
                MapTileLayer(baseMap: ready?.baseMap ?? _defaultBase),
                if (ready != null)
                  MapParcelLayers(
                    snapshot: ready.snapshot,
                    layers: ready.layers,
                    selection: ready.selection,
                  ),
                if (ready?.drawing != null) _drawingLayer(ready!.drawing!),
                MapAttribution(baseMap: ready?.baseMap ?? _defaultBase),
              ],
            ),
            if (ready == null || ready.querying)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(),
              ),
            if (ready?.drawing?.crosshair ?? false) ..._crosshair(),
            if (ready != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: ParcelInfoDimens.toolbarMaxWidth,
                    ),
                    child: ready.drawing == null
                        ? _topBar(ready)
                        : _toolbar(ready, ready.drawing!),
                  ),
                ),
              ),
            if (ready != null &&
                ready.drawing == null &&
                ready.selection != null)
              SafeArea(
                child: Align(
                  alignment: wide
                      ? Alignment.bottomRight
                      : Alignment.bottomCenter,
                  child: _panel(ready, ready.selection!),
                ),
              ),
          ],
        );
        return ready?.drawing == null
            ? map
            : CallbackShortcuts(
                bindings: _drawingShortcuts(),
                child: Focus(autofocus: true, child: map),
              );
      },
    );
  }

  Map<ShortcutActivator, VoidCallback>
  _drawingShortcuts() => <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _cubit.undo,
    const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _cubit.undo,
    const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
        _cubit.redo,
    const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
        _cubit.redo,
    const SingleActivator(LogicalKeyboardKey.keyY, control: true): _cubit.redo,
    const SingleActivator(LogicalKeyboardKey.delete):
        _cubit.removeSelectedCorner,
    const SingleActivator(LogicalKeyboardKey.backspace):
        _cubit.removeSelectedCorner,
    const SingleActivator(LogicalKeyboardKey.escape): _cubit.cancelDrawing,
  };

  static const _defaultBase = MapTileLayer.defaultBase;

  Widget _drawingLayer(MapDrawingReadModel drawing) {
    final ParcelInfoFormat format = ParcelInfoFormat(
      ParcelInfoLocalKeys.of(context),
    );
    return MapDrawingLayer(
      draft: drawing.draft,
      lengthOf: format.length,
      onSelect: _cubit.selectCorner,
      onDragStart: _cubit.dragStart,
      onDragUpdate: (int index, LatLng point) =>
          _cubit.dragUpdate(index, point, metersPerPixel: _metersPerPixel),
      onDragEnd: _cubit.dragEnd,
      onInsert: _cubit.insertCorner,
    );
  }

  List<Widget> _crosshair() => <Widget>[
    const IgnorePointer(
      child: Center(
        child: Icon(
          Icons.add,
          size: ParcelInfoDimens.crosshair,
          color: ParcelInfoColor.draftStroke,
        ),
      ),
    ),
    SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(BaseDimens.padding.xLarge),
          child: FilledButton.icon(
            onPressed: () => _cubit.placeAtCrosshair(
              _controller.camera.center,
              metersPerPixel: _metersPerPixel,
            ),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: ParcelInfoText(
              ParcelInfoLocalKeys.of(context).addCornerHere,
            ),
          ),
        ),
      ),
    ),
  ];

  Widget _topBar(MapReady state) => MapTopBar(
    compact: !WindowSizeClassEnum.of(MediaQuery.sizeOf(context).width)
        .isAtLeast(WindowSizeClassEnum.medium),
    layers: state.layers,
    baseMap: state.baseMap,
    onToggleLayer: _cubit.toggleLayer,
    onBaseMap: _cubit.setBaseMap,
    onNewDrawing: () => _cubit.startDrawing(),
    onMyLocation: _cubit.locate,
    onPeople: () => context.push(ParcelInfoRouter.people.path()),
    onActivity: () => context.push(ParcelInfoRouter.activity.path()),
    onSignOut: () => context.read<SessionCubit>().signOut(),
  );

  Widget _toolbar(MapReady state, MapDrawingReadModel drawing) =>
      MapDrawingToolbar(
        drawing: drawing,
        onUndo: _cubit.undo,
        onRedo: _cubit.redo,
        onDeleteCorner: _cubit.removeSelectedCorner,
        onCrosshair: (bool on) => _cubit.setCrosshair(on: on),
        onCancel: _cubit.cancelDrawing,
        onFinish: () => _finishDrawing(state, drawing),
      );

  Widget _panel(MapReady state, MapHitReadModel selection) =>
      switch (selection) {
        MapHitNone() => const SizedBox.shrink(),
        MapHitOfficial(:final parcel) => MapOfficialPanel(
          parcel: parcel,
          corrections: state.snapshot.drawingsCorrecting(parcel.id),
          querying: state.querying,
          onDrawReal: () => _cubit.startDrawing(copyFrom: parcel),
          onRefresh: () => _cubit.refresh(parcel),
          onOpenDrawing: (DrawnParcelEntity drawing) =>
              _cubit.focusOn(drawing.id),
          onClose: _cubit.closeSelection,
        ),
        MapHitDrawn(:final DrawnParcelEntity drawing) => MapDrawnPanel(
          drawing: drawing,
          snapshot: state.snapshot,
          canDelete: state.member?.canDelete ?? false,
          onEditShape: () => _cubit.startDrawing(edit: drawing),
          onEditDetails: () => _editDetails(state, drawing),
          onDelete: () => _delete(drawing),
          onOpenOfficial: (parcel) => _cubit.focusOn(parcel.id),
          onOpenOwner: (OwnershipValueObject line) =>
              context.push(ParcelInfoRouter.holdingsOf(line.personId)),
          onClose: _cubit.closeSelection,
        ),
      };
}
