import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// Asks "delete this?" before anything permanent happens.
///
/// [ask] answers true only for an explicit yes; closing the dialog any other
/// way is a no.
class ConfirmDialog {
  ConfirmDialog._();

  static Future<bool> ask(BuildContext context, {required String name}) async {
    final l10n = ParcelInfoLocalKeys.of(context);
    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: ParcelInfoText(l10n.confirmDeleteTitle),
        content: ParcelInfoText(l10n.confirmDeleteBody(name)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: ParcelInfoText(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: ParcelInfoText(l10n.delete),
          ),
        ],
      ),
    );
    return answer ?? false;
  }
}
