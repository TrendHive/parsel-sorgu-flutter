import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_panel_frame.dart';

/// A tap where nothing is stored. Says plainly that asking the registry
/// spends one of today's lookups, and asks only when the member presses.
class MapEmptyPointPanel extends StatelessWidget {
  const MapEmptyPointPanel({
    super.key,
    required this.querying,
    required this.onQuery,
    required this.onClose,
  });

  final bool querying;

  final VoidCallback onQuery;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return MapPanelFrame(
      title: l10n.noParcelStoredTitle,
      onClose: onClose,
      children: <Widget>[
        ParcelInfoText(l10n.noParcelStoredBody),
        SizedBox(height: BaseDimens.height.small),
        FilledButton.icon(
          onPressed: querying ? null : onQuery,
          icon: querying
              ? SizedBox.square(
                  dimension: BaseDimens.size.xSmall,
                  child: const CircularProgressIndicator(),
                )
              : const Icon(Icons.travel_explore),
          label: ParcelInfoText(
            querying ? l10n.querying : l10n.queryRegistryButton,
          ),
        ),
      ],
    );
  }
}
