import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// A person's name, their parent in the family tree, their spouse, whether
/// their shares have passed to their children, and a note.
///
/// [parents] is everyone who may be chosen as the parent — the caller has
/// already left out the person and their descendants — and [spouses]
/// everyone they may marry. [marriedBy] is set when the marriage is stored
/// on the spouse's record: it is shown and cannot be changed here. [open]
/// answers the five values, or null when cancelled.
class PersonDialog extends StatefulWidget {
  const PersonDialog({
    super.key,
    required this.parents,
    required this.spouses,
    required this.marriedBy,
    required this.name,
    required this.parentId,
    required this.spouseId,
    required this.passesToChildren,
    required this.note,
  });

  final List<PersonEntity> parents;

  final List<PersonEntity> spouses;

  final PersonEntity? marriedBy;

  final String name;

  final String? parentId;

  final String? spouseId;

  final bool passesToChildren;

  final String note;

  static Future<
    ({
      String name,
      String? parentId,
      String? spouseId,
      bool passesToChildren,
      String note,
    })?
  >
  open(
    BuildContext context, {
    required List<PersonEntity> parents,
    required List<PersonEntity> spouses,
    PersonEntity? marriedBy,
    String name = CoreConstants.empty,
    String? parentId,
    String? spouseId,
    bool passesToChildren = false,
    String note = CoreConstants.empty,
  }) =>
      showDialog<
        ({
          String name,
          String? parentId,
          String? spouseId,
          bool passesToChildren,
          String note,
        })
      >(
        context: context,
        builder: (_) => PersonDialog(
          parents: parents,
          spouses: spouses,
          marriedBy: marriedBy,
          name: name,
          parentId: parentId,
          spouseId: spouseId,
          passesToChildren: passesToChildren,
          note: note,
        ),
      );

  @override
  State<PersonDialog> createState() => _PersonDialogState();
}

class _PersonDialogState extends State<PersonDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.note,
  );
  late String? _parentId = widget.parentId;
  late String? _spouseId = widget.spouseId;
  late bool _passes = widget.passesToChildren;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop((
    name: _name.text,
    parentId: _parentId,
    spouseId: _spouseId,
    passesToChildren: _passes,
    note: _note.text,
  ));

  Widget _spouseField(AppLocalizations l10n) {
    final PersonEntity? marriedBy = widget.marriedBy;
    if (marriedBy != null) {
      return DropdownButtonFormField<String>(
        initialValue: marriedBy.id,
        isExpanded: true,
        decoration: InputDecoration(labelText: l10n.spouseLabel),
        items: <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(
            value: marriedBy.id,
            child: ParcelInfoText(marriedBy.name),
          ),
        ],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<String?>(
      initialValue: _spouseId,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.spouseLabel),
      items: <DropdownMenuItem<String?>>[
        DropdownMenuItem<String?>(child: ParcelInfoText(l10n.spouseNone)),
        for (final PersonEntity person in widget.spouses)
          DropdownMenuItem<String?>(
            value: person.id,
            child: ParcelInfoText(person.name),
          ),
      ],
      onChanged: (String? id) => setState(() => _spouseId = id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return AlertDialog(
      title: ParcelInfoText(l10n.personDialogTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParcelInfoTextField(
                controller: _name,
                label: l10n.nameLabel,
                autofocus: true,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: ParcelInfoDimens.fieldGap),
              DropdownButtonFormField<String?>(
                initialValue: _parentId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.parentLabel),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    child: ParcelInfoText(l10n.parentNone),
                  ),
                  for (final PersonEntity person in widget.parents)
                    DropdownMenuItem<String?>(
                      value: person.id,
                      child: ParcelInfoText(person.name),
                    ),
                ],
                onChanged: (String? id) => setState(() => _parentId = id),
              ),
              const SizedBox(height: ParcelInfoDimens.fieldGap),
              _spouseField(l10n),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _passes,
                title: ParcelInfoText(l10n.passesToChildrenLabel),
                subtitle: ParcelInfoText(l10n.passesToChildrenHint),
                onChanged: (bool on) => setState(() => _passes = on),
              ),
              ParcelInfoTextField(controller: _note, label: l10n.noteLabel),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: ParcelInfoText(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: ParcelInfoText(l10n.save)),
      ],
    );
  }
}
