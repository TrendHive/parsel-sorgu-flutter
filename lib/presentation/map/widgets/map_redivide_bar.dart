import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/enum/redivide_step_enum.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_redivide_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// The bar over the map while two neighbours are divided again by their
/// deeds.
///
/// It says what to do next — tap the neighbour — or why it cannot be done,
/// and once the new shapes are shown, each one's new area against its deed
/// and its area today. Nothing is stored until the confirm button.
class MapRedivideBar extends StatelessWidget {
  const MapRedivideBar({
    super.key,
    required this.redivide,
    required this.onCancel,
    required this.onConfirm,
  });

  final MapRedivideReadModel redivide;

  final VoidCallback onCancel;

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    final ({List<LatLng> first, List<LatLng> second})? pieces = redivide.pieces;
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.xxMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ParcelInfoText(l10n.redivideTitle, style: text.titleSmall),
            ParcelInfoText(switch (redivide.step) {
              RedivideStepEnum.pickNeighbour => l10n.redividePick,
              RedivideStepEnum.noDeed => l10n.redivideNoDeed,
              RedivideStepEnum.sameDeed => l10n.redivideSameDeed,
              RedivideStepEnum.splitDeed => l10n.redivideSplitDeed,
              RedivideStepEnum.notNeighbours => l10n.redivideNotNeighbours,
              RedivideStepEnum.ready => l10n.redivideReady,
            }, style: text.bodyMedium),
            if (pieces != null) ...<Widget>[
              _piece(
                context,
                format,
                ParcelInfoColor.branch(0),
                redivide.first.name,
                now: redivide.first.outline.areaSquareMeters,
                after: GeoRules.areaSquareMeters(pieces.first),
                deed: redivide.firstDeed!,
              ),
              _piece(
                context,
                format,
                ParcelInfoColor.branch(1),
                redivide.second!.name,
                now: redivide.second!.outline.areaSquareMeters,
                after: GeoRules.areaSquareMeters(pieces.second),
                deed: redivide.secondDeed!,
              ),
            ],
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
                  onPressed: redivide.canConfirm ? onConfirm : null,
                  icon: const Icon(Icons.check),
                  label: ParcelInfoText(l10n.redivideConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _piece(
    BuildContext context,
    ParcelInfoFormat format,
    Color colour,
    String name, {
    required double now,
    required double after,
    required double deed,
  }) => Row(
    children: <Widget>[
      Icon(Icons.square, color: colour),
      SizedBox(width: BaseDimens.width.small),
      Expanded(
        child: ParcelInfoText(
          ParcelInfoLocalKeys.of(context).redividePiece(
            name,
            format.area(after),
            format.area(deed),
            format.area(now),
          ),
        ),
      ),
    ],
  );
}
