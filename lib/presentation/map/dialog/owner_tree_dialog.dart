import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Picks a person from the family tree, shown as a tree that opens and
/// closes.
///
/// The heads of the family come first ([FamilyRules.heads]), each closed. A
/// tap on a person chooses them; the arrow beside a person with children
/// opens or closes them in place, indented under their parent, so a member
/// stops at whatever level the land belongs to — choosing the grandfather,
/// or opening him and choosing one of his sons. People in [excluded] are
/// shown but cannot be chosen (they are already owners).
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
  final Set<String> _opened = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final List<PersonEntity> heads = FamilyRules.heads(widget.persons);
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
              if (heads.isEmpty) ParcelInfoText(l10n.pickOwnerEmpty),
              for (final PersonEntity person in heads) ..._branch(person, 0),
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

  List<Widget> _branch(PersonEntity person, int depth) {
    final List<PersonEntity> children = FamilyRules.childrenOf(
      widget.persons,
      person.id,
    );
    final bool opened = _opened.contains(person.id);
    return <Widget>[
      _tile(person, children.length, depth, opened: opened),
      if (opened && depth < FamilyRules.maxGenerations)
        for (final PersonEntity child in children) ..._branch(child, depth + 1),
    ];
  }

  Widget _tile(
    PersonEntity person,
    int children,
    int depth, {
    required bool opened,
  }) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final bool excluded = widget.excluded.contains(person.id);
    return ListTile(
      contentPadding: EdgeInsetsDirectional.only(
        start: ParcelInfoDimens.treeIndent * depth,
      ),
      enabled: !excluded || children > 0,
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
              icon: Icon(opened ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(
                () =>
                    opened ? _opened.remove(person.id) : _opened.add(person.id),
              ),
            ),
      onTap: excluded ? null : () => Navigator.of(context).pop(person),
    );
  }
}
