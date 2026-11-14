import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/domain/person/enum/holder_kind_enum.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// One owner line: who, their share, and — for a group — its members and
/// what each of them holds. [onOpen] goes to the holder's holdings page.
class MapOwnerTile extends StatelessWidget {
  const MapOwnerTile({
    super.key,
    required this.line,
    required this.snapshot,
    required this.onOpen,
  });

  final OwnershipValueObject line;

  final MapSnapshotReadModel snapshot;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final String share = format.share(line.share);
    return switch (line.kind) {
      HolderKindEnum.person => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person_outline),
        title: ParcelInfoText(
          snapshot.personById(line.holderId)?.name ?? l10n.errorRecordMissing,
        ),
        trailing: ParcelInfoText(share),
        onTap: onOpen,
      ),
      HolderKindEnum.group => _group(
        snapshot.groupById(line.holderId),
        share,
        format,
        l10n.errorRecordMissing,
      ),
    };
  }

  Widget _group(
    PersonGroupEntity? group,
    String share,
    ParcelInfoFormat format,
    String missing,
  ) {
    final List<PersonEntity> members = <PersonEntity>[
      for (final String id in group?.memberIds ?? const <String>[])
        ?snapshot.personById(id),
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.groups_outlined),
      title: ParcelInfoText(group?.name ?? missing),
      subtitle: members.isEmpty
          ? null
          : ParcelInfoText(
              '${members.map((PersonEntity p) => p.name).join(', ')} · '
              '${format.share(line.share.dividedBy(members.length))}',
            ),
      trailing: ParcelInfoText(share),
      onTap: onOpen,
    );
  }
}
