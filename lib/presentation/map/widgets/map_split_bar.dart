import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_split_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// The bar over the map while a drawing is being cut in two.
///
/// It says what to do next — tap two points — then shows the areas of the
/// two pieces, or that the line misses the drawing. The cut is stored only
/// by its confirm button.
class MapSplitBar extends StatelessWidget {
  const MapSplitBar({
    super.key,
    required this.split,
    required this.onCancel,
    required this.onConfirm,
  });

  final MapSplitReadModel split;

  final VoidCallback onCancel;

  final VoidCallback onConfirm;

  static const int _cutPoints = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    final String message = split.points.length < _cutPoints
        ? l10n.splitHint
        : split.canConfirm
        ? l10n.splitReady(
            format.area(GeoRules.areaSquareMeters(split.pieces.first)),
            format.area(GeoRules.areaSquareMeters(split.pieces.last)),
          )
        : l10n.splitMissesHint;
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.xxMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ParcelInfoText(split.drawing.name, style: text.titleSmall),
            ParcelInfoText(message, style: text.bodyMedium),
            SizedBox(height: BaseDimens.height.xxSmall),
            Wrap(
              spacing: BaseDimens.margin.medium,
              runSpacing: BaseDimens.margin.medium,
              children: <Widget>[
                TextButton(
                  onPressed: onCancel,
                  child: ParcelInfoText(l10n.cancel),
                ),
                FilledButton.icon(
                  onPressed: split.canConfirm ? onConfirm : null,
                  icon: const Icon(Icons.content_cut),
                  label: ParcelInfoText(l10n.confirmSplit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
