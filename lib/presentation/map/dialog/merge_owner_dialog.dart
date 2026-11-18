import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/read_model/map_merge_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/dialog/owner_tree_dialog.dart';

/// Asks who owns a merged parcel.
///
/// It starts on the pieces' common ancestor — the father whose land was
/// split among his sons — and "Up to parent" climbs the tree one generation
/// at a time (grandfather, great-grandfather). "Choose another" opens the
/// whole tree. When every piece has the same owners, keeping them is
/// offered too, and is the start when the owners share no ancestor.
///
/// [open] answers `(owner: person)` for a sole owner, `(owner: null)` to
/// keep the owners as they are, or null when the member backs out.
class MergeOwnerDialog extends StatefulWidget {
  const MergeOwnerDialog({
    super.key,
    required this.persons,
    required this.merge,
  });

  final List<PersonEntity> persons;

  final MapMergeReadModel merge;

  static Future<({PersonEntity? owner})?> open(
    BuildContext context, {
    required List<PersonEntity> persons,
    required MapMergeReadModel merge,
  }) => showDialog<({PersonEntity? owner})>(
    context: context,
    builder: (_) => MergeOwnerDialog(persons: persons, merge: merge),
  );

  @override
  State<MergeOwnerDialog> createState() => _MergeOwnerDialogState();
}

class _MergeOwnerDialogState extends State<MergeOwnerDialog> {
  late final PersonEntity? _suggested = FamilyRules.commonAncestor(
    widget.persons,
    widget.merge.ownerIds,
  );
  late PersonEntity? _owner = _suggested;
  late bool _keep = _suggested == null && widget.merge.sameOwners;

  bool get _canKeep => widget.merge.sameOwners;

  Future<void> _choose() async {
    final PersonEntity? picked = await OwnerTreeDialog.open(
      context,
      persons: widget.persons,
    );
    if (picked != null && mounted) {
      setState(() {
        _owner = picked;
        _keep = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final PersonEntity? owner = _owner;
    final PersonEntity? parent = owner == null
        ? null
        : FamilyRules.parentOf(widget.persons, owner);
    return AlertDialog(
      title: ParcelInfoText(l10n.mergeOwnerTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ParcelInfoText(l10n.mergeOwnerHint, style: text.bodySmall),
              SizedBox(height: BaseDimens.height.xxSmall),
              if (owner != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  selected: !_keep,
                  leading: const Icon(Icons.account_tree_outlined),
                  title: ParcelInfoText(owner.name),
                  subtitle: owner.id == _suggested?.id
                      ? ParcelInfoText(l10n.mergeOwnerSuggested)
                      : null,
                  onTap: () => setState(() => _keep = false),
                ),
              Wrap(
                spacing: BaseDimens.margin.medium,
                runSpacing: BaseDimens.margin.medium,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: parent == null
                        ? null
                        : () => setState(() {
                            _owner = parent;
                            _keep = false;
                          }),
                    icon: const Icon(Icons.arrow_upward),
                    label: ParcelInfoText(l10n.mergeOwnerUp),
                  ),
                  OutlinedButton.icon(
                    onPressed: _choose,
                    icon: const Icon(Icons.person_search_outlined),
                    label: ParcelInfoText(l10n.mergeOwnerChoose),
                  ),
                ],
              ),
              if (_canKeep)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _keep,
                  title: ParcelInfoText(l10n.mergeOwnerKeep),
                  onChanged: (bool? on) => setState(() => _keep = on ?? false),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: ParcelInfoText(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _keep || owner != null
              ? () => Navigator.of(context).pop((owner: _keep ? null : owner))
              : null,
          icon: const Icon(Icons.call_merge),
          label: ParcelInfoText(l10n.mergeConfirm),
        ),
      ],
    );
  }
}
