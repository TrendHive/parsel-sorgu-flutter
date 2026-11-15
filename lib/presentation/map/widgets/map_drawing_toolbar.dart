import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_drawing_read_model.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// The bar over the map while drawing.
///
/// It says what to do next, shows the live measurements — corners, area,
/// perimeter, and the difference from the deed area when the drawing
/// corrects a registry parcel — and holds every drawing action, each a full
/// labelled button rather than a bare icon.
class MapDrawingToolbar extends StatelessWidget {
  const MapDrawingToolbar({
    super.key,
    required this.drawing,
    required this.onUndo,
    required this.onRedo,
    required this.onDeleteCorner,
    required this.onCrosshair,
    required this.onCancel,
    required this.onFinish,
  });

  final MapDrawingReadModel drawing;

  final VoidCallback onUndo;

  final VoidCallback onRedo;

  final VoidCallback onDeleteCorner;

  final ValueChanged<bool> onCrosshair;

  final VoidCallback onCancel;

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    final double area = drawing.draft.outline.areaSquareMeters;
    final double? deed = drawing.source?.record.registryAreaSquareMeters;
    final List<String> stats = <String>[
      l10n.drawingCorners(drawing.draft.corners.length),
      if (drawing.draft.canSave) format.area(area),
      if (drawing.draft.canSave)
        format.length(drawing.draft.outline.perimeterMeters),
      if (drawing.draft.canSave && deed != null)
        l10n.areaDifference(
          format.signedArea(area - deed),
          format.percent((area - deed) / deed * _percent),
        ),
    ];
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.xxMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ParcelInfoText(
              drawing.crosshair ? l10n.crosshairHint : l10n.drawingHint,
              style: text.bodyMedium,
            ),
            SizedBox(height: BaseDimens.height.xxxxSmall),
            ParcelInfoText(
              stats.join(_separator),
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: BaseDimens.height.xxSmall),
            Wrap(
              spacing: BaseDimens.margin.medium,
              runSpacing: BaseDimens.margin.medium,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: drawing.draft.canUndo ? onUndo : null,
                  icon: const Icon(Icons.undo),
                  label: ParcelInfoText(l10n.undo),
                ),
                OutlinedButton.icon(
                  onPressed: drawing.draft.canRedo ? onRedo : null,
                  icon: const Icon(Icons.redo),
                  label: ParcelInfoText(l10n.redo),
                ),
                OutlinedButton.icon(
                  onPressed: drawing.draft.selected == null
                      ? null
                      : onDeleteCorner,
                  icon: const Icon(Icons.close),
                  label: ParcelInfoText(l10n.deleteCorner),
                ),
                FilterChip(
                  avatar: const Icon(Icons.center_focus_strong),
                  label: ParcelInfoText(l10n.crosshairMode),
                  selected: drawing.crosshair,
                  onSelected: onCrosshair,
                ),
                TextButton(
                  onPressed: onCancel,
                  child: ParcelInfoText(l10n.cancelDrawing),
                ),
                FilledButton.icon(
                  onPressed: drawing.draft.canSave ? onFinish : null,
                  icon: const Icon(Icons.check),
                  label: ParcelInfoText(l10n.finishDrawing),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const String _separator = ' · ';

  static const double _percent = 100;
}
