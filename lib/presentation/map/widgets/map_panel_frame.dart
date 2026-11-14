import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// The card a selected record's details sit in.
///
/// On a phone it rises from the bottom and takes at most
/// [ParcelInfoDimens.panelMaxHeightFactor] of the screen, so the parcel stays
/// visible above it; on a wide screen the caller places it at the side. It
/// scrolls on its own. [badge] names the layer ("Official record" / "Real
/// boundary") in that layer's [accent] colour.
class MapPanelFrame extends StatelessWidget {
  const MapPanelFrame({
    super.key,
    required this.title,
    required this.children,
    required this.onClose,
    this.subtitle,
    this.badge,
    this.accent,
  });

  final String title;

  final String? subtitle;

  final String? badge;

  final Color? accent;

  final List<Widget> children;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ParcelInfoDimens.panelMaxWidth,
          maxHeight:
              MediaQuery.sizeOf(context).height *
              ParcelInfoDimens.panelMaxHeightFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                BaseDimens.padding.xxxxMedium,
                BaseDimens.padding.xxMedium,
                BaseDimens.padding.xxSmall,
                BaseDimens.padding.none,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (badge != null)
                          ParcelInfoText(
                            badge!,
                            style: text.labelMedium?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ParcelInfoText(title, style: text.titleLarge),
                        if (subtitle != null)
                          ParcelInfoText(subtitle!, style: text.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: ParcelInfoLocalKeys.of(context).close,
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(BaseDimens.padding.xxxxMedium),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
