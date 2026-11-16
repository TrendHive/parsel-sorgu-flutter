import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_audit_line.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_info_row.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_panel_frame.dart';

/// A registry parcel: what the registry says, read-only.
///
/// The first action is the main one — draw the real boundary, starting from
/// a copy of this outline. "Refresh" asks the registry again (one lookup).
/// The real boundaries already drawn for this parcel are listed and open on
/// a tap. [inCompare] says whether it is on the comparison list, which
/// [onCompare] toggles.
class MapOfficialPanel extends StatelessWidget {
  const MapOfficialPanel({
    super.key,
    required this.parcel,
    required this.corrections,
    required this.querying,
    required this.onDrawReal,
    required this.onAssign,
    required this.onRefresh,
    required this.onOpenDrawing,
    required this.inCompare,
    required this.onCompare,
    required this.onClose,
  });

  final OfficialParcelEntity parcel;

  final List<DrawnParcelEntity> corrections;

  final bool querying;

  final VoidCallback onDrawReal;

  final VoidCallback onAssign;

  final VoidCallback onRefresh;

  final ValueChanged<DrawnParcelEntity> onOpenDrawing;

  final bool inCompare;

  final VoidCallback onCompare;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final RegistryRecordValueObject r = parcel.record;
    final TextTheme text = Theme.of(context).textTheme;
    final double? area = r.registryAreaSquareMeters;
    return MapPanelFrame(
      badge: l10n.officialBadge,
      accent: ParcelInfoColor.officialStroke,
      title: l10n.officialParcelTitle(r.block, r.parcel),
      subtitle: <String>[r.neighborhoodName, r.districtName, r.cityName]
          .where((String part) => part.isNotEmpty)
          .join(CoreConstants.comma + CoreConstants.space),
      onClose: onClose,
      children: <Widget>[
        if (!r.isActive)
          Padding(
            padding: EdgeInsets.only(bottom: BaseDimens.padding.medium),
            child: ParcelInfoText(
              l10n.inactiveParcel,
              style: text.bodyMedium?.copyWith(color: ParcelInfoColor.warning),
            ),
          ),
        FilledButton.icon(
          onPressed: onDrawReal,
          icon: const Icon(Icons.draw_outlined),
          label: ParcelInfoText(l10n.drawRealButton),
        ),
        SizedBox(height: BaseDimens.height.xxSmall),
        FilledButton.tonalIcon(
          onPressed: onAssign,
          icon: const Icon(Icons.person_add_alt),
          label: ParcelInfoText(l10n.assignOwner),
        ),
        SizedBox(height: BaseDimens.height.xxSmall),
        OutlinedButton.icon(
          onPressed: onCompare,
          icon: Icon(inCompare ? Icons.playlist_remove : Icons.playlist_add),
          label: ParcelInfoText(
            inCompare ? l10n.compareRemove : l10n.compareAdd,
          ),
        ),
        SizedBox(height: BaseDimens.height.xxSmall),
        OutlinedButton.icon(
          onPressed: querying ? null : onRefresh,
          icon: const Icon(Icons.sync),
          label: ParcelInfoText(querying ? l10n.querying : l10n.refreshButton),
        ),
        SizedBox(height: BaseDimens.height.small),
        if (area != null)
          MapInfoRow(label: l10n.registryAreaLabel, value: format.area(area)),
        MapInfoRow(label: l10n.qualityLabel, value: r.quality),
        MapInfoRow(label: l10n.localityLabel, value: r.locality),
        MapInfoRow(label: l10n.neighborhoodLabel, value: r.neighborhoodName),
        MapInfoRow(label: l10n.districtLabel, value: r.districtName),
        MapInfoRow(label: l10n.cityLabel, value: r.cityName),
        MapInfoRow(label: l10n.sheetLabel, value: r.sheet),
        MapInfoRow(label: l10n.landStatusLabel, value: r.landStatus),
        if (corrections.isNotEmpty) ...<Widget>[
          SizedBox(height: BaseDimens.height.small),
          ParcelInfoText(l10n.correctionsTitle, style: text.titleSmall),
          for (final DrawnParcelEntity drawing in corrections)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.edit_location_alt_outlined,
                color: ParcelInfoColor.drawnStroke,
              ),
              title: ParcelInfoText(drawing.name),
              subtitle: ParcelInfoText(
                format.area(drawing.outline.areaSquareMeters),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenDrawing(drawing),
            ),
        ],
        SizedBox(height: BaseDimens.height.small),
        ParcelInfoText(
          l10n.officialReadOnlyNote,
          style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        MapAuditLine(
          l10n.queriedBy(
            parcel.created.memberName,
            format.date(parcel.created.at),
          ),
        ),
        MapAuditLine(
          l10n.refreshedBy(
            parcel.refreshed.memberName,
            format.date(parcel.refreshed.at),
          ),
        ),
      ],
    );
  }
}
