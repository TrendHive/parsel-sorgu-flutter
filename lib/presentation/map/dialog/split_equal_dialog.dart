import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/input/parcel_info_text_field.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_split_preview.dart';

/// Asks how a drawing is to be cut into equal pieces, and in which direction.
///
/// Who gets the pieces: when the drawing has a single owner who has
/// children, "to the children of the father: 4 equal pieces" gives each
/// child one piece as its sole owner (not offered for a drawing with several
/// owners, where it would hand one owner's children the others' shares).
/// Otherwise a number of pieces is typed, and the pieces keep the drawing's
/// owners.
///
/// The direction is the member's choice, never the app's: a compass bearing
/// of the dividing lines (0° north–south, 90° east–west), set with a slider
/// and one-degree steps. It starts across the parcel's long axis
/// (`GeoRules.suggestedCutBearing`), and a numbered preview — with, for
/// heirs, who gets which number — shows the cut before anything is stored.
///
/// [open] answers the number of pieces, the heirs in the order the pieces
/// are given out (or null), and the bearing; null when the member backs out.
class SplitEqualDialog extends StatefulWidget {
  const SplitEqualDialog({
    super.key,
    required this.drawing,
    required this.snapshot,
  });

  final DrawnParcelEntity drawing;

  final MapSnapshotReadModel snapshot;

  static Future<
    ({int pieces, List<PersonEntity>? heirs, double bearingDegrees})?
  >
  open(
    BuildContext context, {
    required DrawnParcelEntity drawing,
    required MapSnapshotReadModel snapshot,
  }) =>
      showDialog<
        ({int pieces, List<PersonEntity>? heirs, double bearingDegrees})
      >(
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
  late double _bearing =
      GeoRules.suggestedCutBearing(_corners).roundToDouble() %
      GeoRules.halfTurnDegrees;
  late bool _toHeirs = _heirs.isNotEmpty;

  List<LatLng> get _corners => widget.drawing.outline.corners;

  PersonEntity? get _owner => widget.drawing.owners.length == CoreConstants.one
      ? widget.snapshot.personById(widget.drawing.owners.single.personId)
      : null;

  List<PersonEntity> get _heirs {
    final PersonEntity? owner = _owner;
    if (owner == null) return const <PersonEntity>[];
    final List<PersonEntity> children = widget.snapshot.childrenOf(owner.id);
    return children.length < CoreConstants.two ||
            children.length > MapRules.maxPieces
        ? const <PersonEntity>[]
        : children;
  }

  int? get _pieces {
    if (_toHeirs) return _heirs.length;
    final int? value = int.tryParse(_count.text.trim());
    return value != null &&
            value >= CoreConstants.two &&
            value <= MapRules.maxPieces
        ? value
        : null;
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  void _turn(double by) => setState(
    () => _bearing =
        (_bearing + by + GeoRules.halfTurnDegrees) % GeoRules.halfTurnDegrees,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final int? pieces = _pieces;
    final List<List<LatLng>> preview = pieces == null
        ? const <List<LatLng>>[]
        : GeoRules.splitEqual(_corners, pieces, bearingDegrees: _bearing);
    final List<PersonEntity> heirs = _heirs;
    final PersonEntity? owner = _owner;
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
              if (owner != null && heirs.isNotEmpty) ...<Widget>[
                Wrap(
                  spacing: BaseDimens.margin.medium,
                  children: <Widget>[
                    ChoiceChip(
                      label: ParcelInfoText(
                        l10n.splitEqualToChildren(owner.name, heirs.length),
                      ),
                      selected: _toHeirs,
                      onSelected: (_) => setState(() => _toHeirs = true),
                    ),
                    ChoiceChip(
                      label: ParcelInfoText(l10n.splitEqualByCount),
                      selected: !_toHeirs,
                      onSelected: (_) => setState(() => _toHeirs = false),
                    ),
                  ],
                ),
                SizedBox(height: BaseDimens.height.xxSmall),
              ],
              if (!_toHeirs)
                ParcelInfoTextField(
                  controller: _count,
                  label: l10n.splitEqualCount,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              const SizedBox(height: ParcelInfoDimens.fieldGap),
              ParcelInfoText(
                l10n.splitEqualAngle(_bearing.round()),
                style: text.titleSmall,
              ),
              ParcelInfoText(l10n.splitEqualAngleHint, style: text.bodySmall),
              Row(
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.splitEqualAngleLess,
                    icon: const Icon(Icons.rotate_left),
                    onPressed: () => _turn(-_step),
                  ),
                  Expanded(
                    child: Slider(
                      value: _bearing,
                      max: GeoRules.halfTurnDegrees - _step,
                      divisions: (GeoRules.halfTurnDegrees - _step).round(),
                      label: l10n.splitEqualAngle(_bearing.round()),
                      onChanged: (double value) =>
                          setState(() => _bearing = value),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.splitEqualAngleMore,
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () => _turn(_step),
                  ),
                ],
              ),
              MapSplitPreview(outline: _corners, pieces: preview),
              if (_toHeirs && preview.isNotEmpty)
                ParcelInfoText(
                  <String>[
                    for (final (int index, PersonEntity heir) in heirs.indexed)
                      '${index + CoreConstants.one}${CoreConstants.colon}'
                          '${CoreConstants.space}${heir.name}',
                  ].join(_separator),
                  style: text.bodySmall,
                ),
              if (pieces != null && preview.isEmpty)
                ParcelInfoText(l10n.errorSplitMisses, style: text.bodySmall),
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
          onPressed: pieces == null || preview.isEmpty
              ? null
              : () => Navigator.of(context).pop((
                  pieces: pieces,
                  heirs: _toHeirs ? heirs : null,
                  bearingDegrees: _bearing,
                )),
          icon: const Icon(Icons.grid_view_outlined),
          label: ParcelInfoText(l10n.splitEqualButton),
        ),
      ],
    );
  }

  static const double _step = 1;
  static const String _separator = ' · ';
}
