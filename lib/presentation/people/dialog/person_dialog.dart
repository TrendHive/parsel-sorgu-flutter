import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// Name and note of a person. [open] answers both, or null when cancelled.
class PersonDialog extends StatefulWidget {
  const PersonDialog({super.key, required this.name, required this.note});

  final String name;

  final String note;

  static Future<({String name, String note})?> open(
    BuildContext context, {
    String name = CoreConstants.empty,
    String note = CoreConstants.empty,
  }) => showDialog<({String name, String note})>(
    context: context,
    builder: (_) => PersonDialog(name: name, note: note),
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

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() =>
      Navigator.of(context).pop((name: _name.text, note: _note.text));

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return AlertDialog(
      title: ParcelInfoText(l10n.personDialogTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
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
            ParcelInfoTextField(controller: _note, label: l10n.noteLabel),
          ],
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
