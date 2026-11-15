import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Asks how a drawing is to be cut into equal pieces.
///
/// Two ways, one tap each. For every owner of the drawing who has children
/// there is a line "to the children of the father: 4 equal pieces" — each child
/// gets one piece as its sole owner. Or a number of pieces is typed, and the
/// pieces keep the drawing's owners.
///
/// [open] answers the number of pieces and, for the first way, the heirs in
/// the order the pieces are given out; null when the member backs out.
class SplitEqualDialog extends StatefulWidget {
  const SplitEqualDialog({
    super.key,
    required this.drawing,
    required this.snapshot,
  });

  final DrawnParcelEntity drawing;

  final MapSnapshotReadModel snapshot;

  static Future<({int pieces, List<PersonEntity>? heirs})?> open(
    BuildContext context, {
    required DrawnParcelEntity drawing,
    required MapSnapshotReadModel snapshot,
  }) => showDialog<({int pieces, List<PersonEntity>? heirs})>(
    context: context,
    builder: (_) => SplitEqualDialog(drawing: drawing, snapshot: snapshot),
  );

  @override
  State<SplitEqualDialog> createState() => _SplitEqualDialogState();
}

class _SplitEqualDialogState extends State<SplitEqualDialog> {
  final TextEditingController _count = TextEditingController(
    text: '${CoreConstants.two}',
  );

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  int? get _pieces {
    final int? value = int.tryParse(_count.text.trim());
    return value != null &&
            value >= CoreConstants.two &&
            value <= MapRules.maxPieces
        ? value
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    return AlertDialog(
      title: ParcelInfoText(l10n.splitEqualTitle),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ParcelInfoText(l10n.splitEqualNote, style: text.bodySmall),
              SizedBox(height: BaseDimens.height.xxSmall),
              for (final OwnershipValueObject line in widget.drawing.owners)
                ..._toChildren(line),
              const Divider(),
              ParcelInfoText(l10n.splitEqualByCount, style: text.titleSmall),
              SizedBox(height: BaseDimens.height.xxSmall),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ParcelInfoTextField(
                      controller: _count,
                      label: l10n.splitEqualCount,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: BaseDimens.width.small),
                  FilledButton.tonalIcon(
                    onPressed: _pieces == null
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .pop((pieces: _pieces!, heirs: null)),
                    icon: const Icon(Icons.grid_view_outlined),
                    label: ParcelInfoText(l10n.splitEqualButton),
                  ),
                ],
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
      ],
    );
  }

  List<Widget> _toChildren(OwnershipValueObject line) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final PersonEntity? owner = widget.snapshot.personById(line.personId);
    final List<PersonEntity> heirs = widget.snapshot.childrenOf(line.personId);
    if (owner == null ||
        heirs.length < CoreConstants.two ||
        heirs.length > MapRules.maxPieces) {
      return const <Widget>[];
    }
    return <Widget>[
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.account_tree_outlined),
        title: ParcelInfoText(
          l10n.splitEqualToChildren(owner.name, heirs.length),
        ),
        subtitle: ParcelInfoText(
          heirs.map((PersonEntity p) => p.name).join(_separator),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context).pop((pieces: heirs.length, heirs: heirs)),
      ),
    ];
  }

  static const String _separator = ', ';
}
