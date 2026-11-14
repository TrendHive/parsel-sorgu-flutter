import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// A group's name, members and note. Members are ticked from the family's
/// people. [open] answers all three, or null when cancelled.
class GroupDialog extends StatefulWidget {
  const GroupDialog({
    super.key,
    required this.persons,
    required this.name,
    required this.memberIds,
    required this.note,
  });

  final List<PersonEntity> persons;

  final String name;

  final List<String> memberIds;

  final String note;

  static Future<({String name, List<String> memberIds, String note})?> open(
    BuildContext context, {
    required List<PersonEntity> persons,
    String name = CoreConstants.empty,
    List<String> memberIds = const <String>[],
    String note = CoreConstants.empty,
  }) => showDialog<({String name, List<String> memberIds, String note})>(
    context: context,
    builder: (_) => GroupDialog(
      persons: persons,
      name: name,
      memberIds: memberIds,
      note: note,
    ),
  );

  @override
  State<GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<GroupDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.note,
  );
  late final Set<String> _members = widget.memberIds.toSet();

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return AlertDialog(
      title: ParcelInfoText(l10n.groupDialogTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ParcelInfoTextField(
                controller: _name,
                label: l10n.nameLabel,
                autofocus: true,
              ),
              const SizedBox(height: ParcelInfoDimens.fieldGap),
              ParcelInfoText(
                l10n.groupMembersLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final PersonEntity person in widget.persons)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _members.contains(person.id),
                  title: ParcelInfoText(person.name),
                  onChanged: (bool? on) => setState(
                    () => on ?? false
                        ? _members.add(person.id)
                        : _members.remove(person.id),
                  ),
                ),
              const SizedBox(height: ParcelInfoDimens.fieldGap),
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
        FilledButton(
          onPressed: () => Navigator.of(context).pop((
            name: _name.text,
            memberIds: <String>[
              for (final PersonEntity p in widget.persons)
                if (_members.contains(p.id)) p.id,
            ],
            note: _note.text,
          )),
          child: ParcelInfoText(l10n.save),
        ),
      ],
    );
  }
}
