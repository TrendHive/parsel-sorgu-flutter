import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// One owner line: who the share is recorded on and how much. When that
/// person's shares have passed on, the children and what each of them gets
/// are shown beneath. [onOpen] goes to the person's holdings page.
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
    final PersonEntity? person = snapshot.personById(line.personId);
    final List<PersonEntity> heirs =
        person != null && FamilyRules.passes(snapshot.persons, person)
        ? snapshot.childrenOf(person.id)
        : const <PersonEntity>[];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        heirs.isEmpty ? Icons.person_outline : Icons.account_tree_outlined,
      ),
      title: ParcelInfoText(person?.name ?? l10n.errorRecordMissing),
      subtitle: heirs.isEmpty
          ? null
          : ParcelInfoText(
              l10n.passedToChildren(
                heirs.map((PersonEntity p) => p.name).join(_separator),
                format.share(line.share.dividedBy(heirs.length)),
              ),
            ),
      trailing: ParcelInfoText(format.share(line.share)),
      onTap: onOpen,
    );
  }

  static const String _separator = ', ';
}
