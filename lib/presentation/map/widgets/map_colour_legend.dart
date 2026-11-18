import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Says which colour is which owner — or which branch of the family, while
/// the map is coloured by a level of the tree.
///
/// [branches] are the people who hold something, in the order
/// their colours were given out; after them come the colour of a drawing
/// several branches share and the colour of one nobody owns yet.
///
/// It folds away to a single button so it never hides the map: [initiallyOpen]
/// is false on a phone, and an open legend scrolls within
/// [ParcelInfoDimens.legendMaxHeightFactor] of the screen.
class MapColourLegend extends StatefulWidget {
  const MapColourLegend({
    super.key,
    required this.branches,
    this.initiallyOpen = true,
  });

  final List<PersonEntity> branches;

  final bool initiallyOpen;

  @override
  State<MapColourLegend> createState() => _MapColourLegendState();
}

class _MapColourLegendState extends State<MapColourLegend> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    if (!_open) {
      return Padding(
        padding: EdgeInsets.all(BaseDimens.margin.medium),
        child: FloatingActionButton.small(
          heroTag: null,
          tooltip: l10n.legendShow,
          onPressed: () => setState(() => _open = true),
          child: const Icon(Icons.palette_outlined),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ParcelInfoDimens.legendMaxWidth,
          maxHeight:
              MediaQuery.sizeOf(context).height *
              ParcelInfoDimens.legendMaxHeightFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                tooltip: l10n.legendHide,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _open = false),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  BaseDimens.padding.medium,
                  BaseDimens.padding.none,
                  BaseDimens.padding.medium,
                  BaseDimens.padding.medium,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final (int index, PersonEntity person)
                        in widget.branches.indexed)
                      _row(context, ParcelInfoColor.branch(index), person.name),
                    _row(
                      context,
                      ParcelInfoColor.sharedBranches,
                      l10n.colourShared,
                    ),
                    _row(
                      context,
                      ParcelInfoColor.unowned,
                      l10n.colourUnassigned,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Color colour, String label) => Padding(
    padding: EdgeInsets.symmetric(vertical: BaseDimens.padding.xxSmall),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: ParcelInfoDimens.legendDot,
          height: ParcelInfoDimens.legendDot,
          decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
        ),
        SizedBox(width: BaseDimens.width.small),
        Flexible(
          child: ParcelInfoText(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
