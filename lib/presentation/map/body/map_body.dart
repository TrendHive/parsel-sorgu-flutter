import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/auth/cubit/session_cubit.dart';
import 'package:parcel_atlas/application/map/cubit/map_cubit.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_drawing_read_model.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/enum/camera_move_enum.dart';
import 'package:parcel_atlas/domain/map/enum/map_notice_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_hit_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/presentation/domain_ui/dialog/confirm/confirm_dialog.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/window_size_class_enum.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/feedback/parcel_info_toast.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/dialog/drawing_choice_dialog.dart';
import 'package:parcel_atlas/presentation/map/dialog/owner_tree_dialog.dart';
import 'package:parcel_atlas/presentation/map/dialog/parcel_search_dialog.dart';
import 'package:parcel_atlas/presentation/map/dialog/save_drawing_dialog.dart';
import 'package:parcel_atlas/presentation/map/dialog/split_equal_dialog.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_attribution.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_colour_legend.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_compare_bar.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_drawing_layer.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_drawing_toolbar.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_drawn_panel.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_official_panel.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_parcel_layers.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_redivide_bar.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_redivide_layer.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_split_bar.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_split_layer.dart';
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
        MapNoticeEnum.useApp => l10n.noticeUseApp,
      });
    }
  }

  void _focus(List<LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == CoreConstants.one) {
      _controller.move(points.single, _focusZoom);
      return;
    }
    final LatLngBounds visible = _controller.camera.visibleBounds;
    switch (MapRules.cameraMove(
      visible: (southWest: visible.southWest, northEast: visible.northEast),
      target: points,
    )) {
      case CameraMoveEnum.stay:
        return;
      case CameraMoveEnum.pan:
        _controller.move(GeoRules.centre(points), _controller.camera.zoom);
        return;
      case CameraMoveEnum.frame:
        break;
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

  Future<void> _editDetails(
    MapReady state,
    DrawnParcelEntity drawing, {
    String? officialParcelId,
    String? addedPersonId,
  }) async {
    final DrawingDetailsValueObject? details = await SaveDrawingDialog.open(
      context,
      snapshot: state.snapshot,
      name: drawing.name,
      owners: drawing.owners,
      note: drawing.note,
      officialParcelId: drawing.officialParcelId ?? officialParcelId,
      addedPersonId: addedPersonId,
    );
    if (details != null) await _cubit.saveDetails(drawing, details);
  }

  Future<void> _search(MapReady state) async {
    final ({int neighborhoodId, String block, String parcel})? query =
        await ParcelSearchDialog.open(
          context,
          neighbourhoods: state.snapshot.neighbourhoods,
        );
    if (query != null) {
      await _cubit.queryByNumber(
        neighborhoodId: query.neighborhoodId,
        block: query.block,
        parcel: query.parcel,
      );
    }
  }

  Future<void> _assign(MapReady state, OfficialParcelEntity parcel) async {
    final List<DrawnParcelEntity> corrections = state.snapshot
        .drawingsCorrecting(parcel);
    final DrawnParcelEntity? onto = switch (corrections.length) {
      0 => null,
      1 => corrections.single,
      _ => await DrawingChoiceDialog.open(context, drawings: corrections),
    };
    if (!mounted || (corrections.isNotEmpty && onto == null)) return;
    if (onto != null) {
      await _assignDrawn(state, onto, officialParcelId: parcel.id);
      return;
    }
    final String name = ParcelInfoLocalKeys.of(context)
        .drawingNameDefault(parcel.label);
    final PersonEntity? person = await OwnerTreeDialog.open(
      context,
      persons: state.snapshot.persons,
    );
    if (person != null) {
      await _cubit.assignOwner(parcel, person, name: name);
    }
  }

  Future<void> _assignDrawn(
    MapReady state,
    DrawnParcelEntity drawing, {
    String? officialParcelId,
  }) async {
    final PersonEntity? person = await OwnerTreeDialog.open(
      context,
      persons: state.snapshot.persons,
      excluded: <String>{
        for (final OwnershipValueObject line in drawing.owners) line.personId,
      },
    );
    if (person == null || !mounted) return;
    if (drawing.owners.isEmpty) {
      await _cubit.assignOwnerTo(drawing, person, officialParcelId);
      return;
    }
    await _editDetails(
      state,
      drawing,
      officialParcelId: officialParcelId,
      addedPersonId: person.id,
    );
  }

  Future<void> _splitEqual(MapReady state, DrawnParcelEntity drawing) async {
    final ({int pieces, List<PersonEntity>? heirs})? choice =
        await SplitEqualDialog.open(
          context,
          drawing: drawing,
          snapshot: state.snapshot,
        );
    if (choice != null) {
      await _cubit.splitEqual(
        drawing,
        pieces: choice.pieces,
        heirs: choice.heirs,
      );
    }
  }

  List<String> _colourLabels(MapReady state) {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    final List<PersonEntity> persons = state.snapshot.persons;
    return <String>[
      for (
        int level = CoreConstants.zero;
        level < state.snapshot.generations;
        level++
      )
        l10n.colourLevel(
          level + CoreConstants.one,
          persons
              .where(
                (PersonEntity p) => FamilyRules.depthOf(persons, p.id) == level,
              )
              .map((PersonEntity p) => p.name)
              .join(CoreConstants.comma + CoreConstants.space),
        ),
    ];
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
                    colourLevel: ready.colourLevel,
                  ),
                if (ready?.drawing != null) _drawingLayer(ready!.drawing!),
                if (ready?.split != null) MapSplitLayer(split: ready!.split!),
                if (ready?.redivide != null)
                  MapRedivideLayer(redivide: ready!.redivide!),
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
                    child: ready.redivide != null
                        ? MapRedivideBar(
                            redivide: ready.redivide!,
                            onCancel: _cubit.cancelRedivide,
                            onConfirm: _cubit.confirmRedivide,
                          )
                        : ready.split != null
                        ? MapSplitBar(
                            split: ready.split!,
                            onCancel: _cubit.cancelSplit,
                            onConfirm: _cubit.confirmSplit,
                          )
                        : ready.drawing == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _topBar(ready),
                              if (ready.compareIds.isNotEmpty)
                                MapCompareBar(
                                  count: ready.compareIds.length,
                                  onOpen: () => context.push(
                                    ParcelInfoRouter.compareOf(
                                      ready.compareIds,
                                    ),
                                  ),
                                  onClear: _cubit.clearCompare,
                                ),
                            ],
                          )
                        : _toolbar(ready, ready.drawing!),
                  ),
                ),
              ),
            if (ready != null &&
                ready.snapshot.drawings.isNotEmpty &&
                ready.drawing == null &&
                ready.split == null &&
                ready.redivide == null)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: MapColourLegend(
                    branches: ready.snapshot.branchesAt(ready.colourLevel),
                  ),
                ),
              ),
            if (ready != null &&
                ready.drawing == null &&
                ready.split == null &&
                ready.redivide == null &&
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
    colourLevel: state.colourLevel,
    colourLabels: _colourLabels(state),
    onColour: _cubit.setColourLevel,
    onSearch: () => _search(state),
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
          corrections: state.snapshot.drawingsCorrecting(parcel),
          querying: state.querying,
          onDrawReal: () => _cubit.startDrawing(copyFrom: parcel),
          onAssign: () => _assign(state, parcel),
          inCompare: state.compareIds.contains(parcel.id),
          onCompare: () => _cubit.toggleCompare(parcel.id),
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
          onAssign: () => _assignDrawn(state, drawing),
          inCompare: state.compareIds.contains(drawing.id),
          onCompare: () => _cubit.toggleCompare(drawing.id),
          onSplit: () => _cubit.startSplit(drawing),
          onRedivide: () => _cubit.startRedivide(drawing),
          onSplitEqual: () => _splitEqual(state, drawing),
          onDelete: () => _delete(drawing),
          onOpenOfficial: (parcel) => _cubit.focusOn(parcel.id),
          onOpenOwner: (OwnershipValueObject line) =>
              context.push(ParcelInfoRouter.holdingsOf(line.personId)),
          onClose: _cubit.closeSelection,
        ),
      };
}
