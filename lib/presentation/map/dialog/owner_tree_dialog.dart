import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Picks a person by walking down the family tree, one generation at a time.
///
/// It opens on the eldest generation. A tap on a person chooses them; the
/// arrow beside a person with children goes down to those children instead,
/// so a member stops at whatever level the land belongs to — choosing the
/// grandfather, or going in and choosing one of his sons. People in
/// [excluded] are shown but cannot be chosen (they are already owners).
///
/// [open] answers the person, or null when the member backs out.
class OwnerTreeDialog extends StatefulWidget {
  const OwnerTreeDialog({
    super.key,
    required this.persons,
    this.excluded = const <String>{},
  });

  final List<PersonEntity> persons;

  final Set<String> excluded;

  static Future<PersonEntity?> open(
    BuildContext context, {
    required List<PersonEntity> persons,
    Set<String> excluded = const <String>{},
  }) => showDialog<PersonEntity>(
    context: context,
    builder: (_) => OwnerTreeDialog(persons: persons, excluded: excluded),
  );

  @override
  State<OwnerTreeDialog> createState() => _OwnerTreeDialogState();
}

class _OwnerTreeDialogState extends State<OwnerTreeDialog> {
  final List<PersonEntity> _path = <PersonEntity>[];

  List<PersonEntity> get _shown {
    if (_path.isNotEmpty) {
      return FamilyRules.childrenOf(widget.persons, _path.last.id);
    }
    final Set<String> ids = <String>{
      for (final PersonEntity p in widget.persons) p.id,
    };
    return widget.persons
        .where((PersonEntity p) => !ids.contains(p.parentId))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final List<PersonEntity> shown = _shown;
    return AlertDialog(
      title: ParcelInfoText(l10n.assignOwnerTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ParcelInfoText(l10n.assignOwnerHint, style: text.bodySmall),
              SizedBox(height: BaseDimens.height.xxSmall),
              if (_path.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.arrow_upward),
                  title: ParcelInfoText(
                    _path.map((PersonEntity p) => p.name).join(_separator),
                    style: text.titleSmall,
                  ),
                  subtitle: ParcelInfoText(l10n.treeBack),
                  onTap: () => setState(_path.removeLast),
                ),
              if (shown.isEmpty) ParcelInfoText(l10n.pickOwnerEmpty),
              for (final PersonEntity person in shown) _tile(person),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: ParcelInfoText(l10n.cancel),
        ),
      ],
    );
  }

  Widget _tile(PersonEntity person) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final int children = FamilyRules.childrenOf(
      widget.persons,
      person.id,
    ).length;
    return ListTile(
      enabled: !widget.excluded.contains(person.id) || children > 0,
      leading: Icon(
        FamilyRules.passes(widget.persons, person)
            ? Icons.account_tree_outlined
            : Icons.person_outline,
      ),
      title: ParcelInfoText(person.name),
      subtitle: children == 0
          ? null
          : ParcelInfoText(l10n.childCount(children)),
      trailing: children == 0
          ? null
          : IconButton(
              tooltip: l10n.showChildren,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _path.add(person)),
            ),
      onTap: widget.excluded.contains(person.id)
          ? null
          : () => Navigator.of(context).pop(person),
    );
  }

  static const String _separator = ' › ';
}
