import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/read_model/parcel_comparison_read_model.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_audit_line.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_info_row.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_owner_tile.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_panel_frame.dart';

/// A drawn (real) boundary: its exact measurements, how it compares with
/// the deed, who owns which share, and the actions on it.
///
/// [canDelete] shows the delete action only to the main account.
/// [inCompare] says whether it is on the comparison list, which [onCompare]
/// toggles.
class MapDrawnPanel extends StatelessWidget {
  const MapDrawnPanel({
    super.key,
    required this.drawing,
    required this.snapshot,
    required this.canDelete,
    required this.onEditShape,
    required this.onEditDetails,
    required this.onAssign,
    required this.onSplit,
    required this.onSplitEqual,
    required this.onRedivide,
    required this.onDelete,
    required this.onOpenOfficial,
    required this.onOpenOwner,
    required this.inCompare,
    required this.onCompare,
    required this.onClose,
  });

  final DrawnParcelEntity drawing;

  final MapSnapshotReadModel snapshot;

  final bool canDelete;

  final VoidCallback onEditShape;

  final VoidCallback onEditDetails;

  final VoidCallback onAssign;

  final VoidCallback onSplit;

  final VoidCallback onSplitEqual;

  final VoidCallback onRedivide;

  final VoidCallback onDelete;

  final ValueChanged<OfficialParcelEntity> onOpenOfficial;

  final ValueChanged<OwnershipValueObject> onOpenOwner;

  final bool inCompare;

  final VoidCallback onCompare;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final TextTheme text = Theme.of(context).textTheme;
    final OfficialParcelEntity? official = snapshot.officialById(
      drawing.officialParcelId,
    );
    final ParcelComparisonReadModel? comparison = official == null
        ? null
        : ParcelComparisonReadModel.of(drawing, official);
    final List<double> edges = drawing.outline.edgeLengthsMeters;
    return MapPanelFrame(
      badge: l10n.drawnBadge,
      accent: ParcelInfoColor.drawnStroke,
      title: drawing.name,
      subtitle: official == null
          ? null
          : '${official.record.neighborhoodName} · ${official.label}',
      onClose: onClose,
      children: <Widget>[
        MapInfoRow(
          label: l10n.measuredAreaLabel,
          value: format.area(drawing.outline.areaSquareMeters),
        ),
        MapInfoRow(
          label: l10n.perimeterLabel,
          value: format.length(drawing.outline.perimeterMeters),
        ),
        if (comparison != null) ...<Widget>[
          MapInfoRow(
            label: l10n.registryAreaLabel,
            value: format.area(comparison.registryArea),
          ),
          ParcelInfoText(
            l10n.areaDifference(
              format.signedArea(comparison.difference),
              format.percent(comparison.differencePercent),
            ),
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          TextButton.icon(
            onPressed: () => onOpenOfficial(official),
            icon: const Icon(
              Icons.gavel_outlined,
              color: ParcelInfoColor.officialStroke,
            ),
            label: ParcelInfoText(
              '${l10n.linkedOfficialLabel}: ${official!.label}',
            ),
          ),
        ],
        SizedBox(height: BaseDimens.height.small),
        ParcelInfoText(l10n.ownersTitle, style: text.titleMedium),
        if (drawing.owners.isEmpty) ParcelInfoText(l10n.noOwners),
        for (final OwnershipValueObject line in drawing.owners)
          MapOwnerTile(
            line: line,
            snapshot: snapshot,
            onOpen: () => onOpenOwner(line),
          ),
        if (drawing.owners.isNotEmpty) ...<Widget>[
          ParcelInfoText(l10n.sharesTotal(format.share(drawing.allocated))),
          if (!drawing.isFullyAllocated)
            ParcelInfoText(
              l10n.sharesIncomplete,
              style: text.bodySmall?.copyWith(color: ParcelInfoColor.warning),
            ),
        ],
        if (drawing.note.isNotEmpty) ...<Widget>[
          SizedBox(height: BaseDimens.height.small),
          MapInfoRow(label: l10n.noteLabel, value: drawing.note),
        ],
        SizedBox(height: BaseDimens.height.small),
        Wrap(
          spacing: BaseDimens.margin.medium,
          runSpacing: BaseDimens.margin.medium,
          children: <Widget>[
            FilledButton.icon(
              onPressed: onEditDetails,
              icon: const Icon(Icons.edit_note),
              label: ParcelInfoText(l10n.editDetails),
            ),
            FilledButton.tonalIcon(
              onPressed: onAssign,
              icon: const Icon(Icons.person_add_alt),
              label: ParcelInfoText(l10n.assignOwner),
            ),
            OutlinedButton.icon(
              onPressed: onCompare,
              icon: Icon(
                inCompare ? Icons.playlist_remove : Icons.playlist_add,
              ),
              label: ParcelInfoText(
                inCompare ? l10n.compareRemove : l10n.compareAdd,
              ),
            ),
            OutlinedButton.icon(
              onPressed: onEditShape,
              icon: const Icon(Icons.polyline_outlined),
              label: ParcelInfoText(l10n.editShape),
            ),
            OutlinedButton.icon(
              onPressed: onSplit,
              icon: const Icon(Icons.content_cut),
              label: ParcelInfoText(l10n.splitButton),
            ),
            OutlinedButton.icon(
              onPressed: onSplitEqual,
              icon: const Icon(Icons.grid_view_outlined),
              label: ParcelInfoText(l10n.splitEqualButton),
            ),
            OutlinedButton.icon(
              onPressed: onRedivide,
              icon: const Icon(Icons.compare_arrows),
              label: ParcelInfoText(l10n.redivideButton),
            ),
            if (canDelete)
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: ParcelInfoText(l10n.delete),
              ),
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: ParcelInfoText(l10n.edgesLabel),
          children: <Widget>[
            for (int i = CoreConstants.zero; i < edges.length; i++)
              MapInfoRow(
                label:
                    '${i + CoreConstants.one}–${(i + CoreConstants.one) % edges.length + CoreConstants.one}',
                value: format.length(edges[i]),
              ),
          ],
        ),
        MapAuditLine(
          l10n.createdBy(
            drawing.created.memberName,
            format.date(drawing.created.at),
          ),
        ),
        MapAuditLine(
          l10n.updatedBy(
            drawing.updated.memberName,
            format.date(drawing.updated.at),
          ),
        ),
      ],
    );
  }
}
