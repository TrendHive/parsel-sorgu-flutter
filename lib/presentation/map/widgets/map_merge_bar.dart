import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_merge_read_model.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// The bar over the map while pieces are merged back into one.
///
/// It says to tap the neighbouring pieces, then how many are chosen and the
/// merged area — or that they do not join. [onConfirm] goes on to choosing
/// the owner; nothing is stored before that.
class MapMergeBar extends StatelessWidget {
  const MapMergeBar({
    super.key,
    required this.merge,
    required this.onCancel,
    required this.onConfirm,
  });

  final MapMergeReadModel merge;

  final VoidCallback onCancel;

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.xxMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ParcelInfoText(l10n.mergeTitle, style: text.titleSmall),
            ParcelInfoText(
              merge.drawings.length < CoreConstants.two
                  ? l10n.mergePick
                  : merge.canConfirm
                  ? l10n.mergeReady(
                      merge.drawings.length,
                      format.area(merge.area),
                    )
                  : l10n.errorMergeMisses,
              style: text.bodyMedium,
            ),
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
                  onPressed: merge.canConfirm ? onConfirm : null,
                  icon: const Icon(Icons.call_merge),
                  label: ParcelInfoText(l10n.mergeConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
