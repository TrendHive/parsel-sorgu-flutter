import 'package:either_dart/either.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_details_value_object.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/copy/exception_copy.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/dialog/owner_draft.dart';
import 'package:parcel_atlas/presentation/map/dialog/owner_tree_dialog.dart';

/// Name, owners with their shares, and a note — asked when a drawing is
/// finished, and again by "Edit details".
///
/// [addedPersonId], when given, is a co-owner being assigned: their line is
/// added with an empty share for the member to fill in.
///
/// [open] answers the details, or null when the member backs out. Shares are
/// typed as a deed writes them ("1/4"); the running total shows under the
/// list, and nothing is accepted that the domain would refuse — an empty
/// name, a share that is not a fraction, or shares above the whole.
class SaveDrawingDialog extends StatefulWidget {
  const SaveDrawingDialog({
    super.key,
    required this.snapshot,
    required this.name,
    required this.owners,
    required this.note,
    required this.officialParcelId,
    this.addedPersonId,
  });

  final MapSnapshotReadModel snapshot;

  final String name;

  final List<OwnershipValueObject> owners;

  final String note;

  final String? officialParcelId;

  final String? addedPersonId;

  static Future<DrawingDetailsValueObject?> open(
    BuildContext context, {
    required MapSnapshotReadModel snapshot,
    required String name,
    required List<OwnershipValueObject> owners,
    required String note,
    required String? officialParcelId,
    String? addedPersonId,
  }) => showDialog<DrawingDetailsValueObject>(
    context: context,
    builder: (_) => SaveDrawingDialog(
      snapshot: snapshot,
      name: name,
      owners: owners,
      note: note,
      officialParcelId: officialParcelId,
      addedPersonId: addedPersonId,
    ),
  );

  @override
  State<SaveDrawingDialog> createState() => _SaveDrawingDialogState();
}

class _SaveDrawingDialogState extends State<SaveDrawingDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.note,
  );
  late final List<OwnerDraft> _owners = <OwnerDraft>[
    for (final OwnershipValueObject line in widget.owners)
      OwnerDraft(
        personId: line.personId,
        share: '${line.share.numerator}/${line.share.denominator}',
      ),
    if (widget.addedPersonId case final String added)
      OwnerDraft(personId: added, share: CoreConstants.empty),
  ];
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    for (final OwnerDraft owner in _owners) {
      owner.share.dispose();
    }
    super.dispose();
  }

  String _holderName(OwnerDraft owner) =>
      widget.snapshot.personById(owner.personId)?.name ?? owner.personId;

  Future<void> _addOwner() async {
    final PersonEntity? picked = await OwnerTreeDialog.open(
      context,
      persons: widget.snapshot.persons,
      excluded: <String>{for (final OwnerDraft o in _owners) o.personId},
    );
    if (picked != null) {
      setState(
        () => _owners.add(OwnerDraft(personId: picked.id, share: _wholeText)),
      );
    }
  }

  ShareValueObject? get _total {
    ShareValueObject total = ShareValueObject.none;
    for (final OwnerDraft owner in _owners) {
      final ShareValueObject? share = ShareValueObject.tryParse(
        owner.share.text,
      );
      if (share == null) return null;
      total = total.plus(share);
    }
    return total;
  }

  void _save() {
    final l10n = ParcelInfoLocalKeys.of(context);
    final List<OwnershipValueObject> lines = <OwnershipValueObject>[];
    for (final OwnerDraft owner in _owners) {
      final ShareValueObject? share = ShareValueObject.tryParse(
        owner.share.text,
      );
      if (share == null) {
        setState(() => _error = l10n.invalidShare);
        return;
      }
      lines.add(OwnershipValueObject(personId: owner.personId, share: share));
    }
    final DrawingDetailsValueObject details = DrawingDetailsValueObject((
      name: _name.text,
      officialParcelId: widget.officialParcelId,
      owners: lines,
      note: _note.text,
    ));
    switch (details.valueObject) {
      case Left(:final BaseException value):
        setState(() => _error = ExceptionCopy.of(l10n, value));
      case Right():
        Navigator.of(context).pop(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    final ShareValueObject? total = _total;
    final TextTheme text = Theme.of(context).textTheme;
    return AlertDialog(
      title: ParcelInfoText(l10n.saveDrawingTitle),
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
              SizedBox(height: BaseDimens.height.small),
              ParcelInfoText(l10n.ownersTitle, style: text.titleMedium),
              if (_owners.isEmpty) ParcelInfoText(l10n.noOwners),
              for (final OwnerDraft owner in _owners)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: BaseDimens.padding.xxSmall,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.person_outline),
                      SizedBox(width: BaseDimens.width.small),
                      Expanded(child: ParcelInfoText(_holderName(owner))),
                      SizedBox(
                        width: ParcelInfoDimens.shareFieldWidth,
                        child: ParcelInfoTextField(
                          controller: owner.share,
                          label: l10n.shareLabel,
                          hint: l10n.shareHint,
                          keyboardType: TextInputType.text,
                          onChanged: (_) => setState(() => _error = null),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() {
                          _owners.remove(owner);
                          owner.share.dispose();
                        }),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addOwner,
                  icon: const Icon(Icons.person_add_alt),
                  label: ParcelInfoText(l10n.addOwner),
                ),
              ),
              if (_owners.isNotEmpty)
                ParcelInfoText(
                  total == null
                      ? l10n.invalidShare
                      : l10n.sharesTotal(format.share(total)),
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              SizedBox(height: BaseDimens.height.small),
              ParcelInfoTextField(
                controller: _note,
                label: l10n.noteLabel,
                maxLines: _noteLines,
              ),
              if (_error != null) ...<Widget>[
                SizedBox(height: BaseDimens.height.xxSmall),
                ParcelInfoText(
                  _error!,
                  style: text.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
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

  static const String _wholeText = '1/1';

  static const int _noteLines = 3;
}
