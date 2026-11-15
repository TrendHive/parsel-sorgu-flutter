import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// The small bar under the map's top bar while parcels are put aside for
/// comparison: how many, a button that opens the comparison, and one that
/// empties the list.
class MapCompareBar extends StatelessWidget {
  const MapCompareBar({
    super.key,
    required this.count,
    required this.onOpen,
    required this.onClear,
  });

  final int count;

  final VoidCallback onOpen;

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: BaseDimens.margin.medium),
      child: Padding(
        padding: EdgeInsets.all(BaseDimens.padding.xxSmall),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.compare_arrows),
              label: ParcelInfoText(l10n.compareOpen(count)),
            ),
            IconButton(
              tooltip: l10n.compareClear,
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}
