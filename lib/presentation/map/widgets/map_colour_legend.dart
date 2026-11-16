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
class MapColourLegend extends StatelessWidget {
  const MapColourLegend({super.key, required this.branches});

  final List<PersonEntity> branches;

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    return Card(
      margin: EdgeInsets.all(BaseDimens.margin.medium),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ParcelInfoDimens.legendMaxWidth,
        ),
        child: Padding(
          padding: EdgeInsets.all(BaseDimens.padding.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final (int index, PersonEntity person) in branches.indexed)
                _row(context, ParcelInfoColor.branch(index), person.name),
              _row(context, ParcelInfoColor.sharedBranches, l10n.colourShared),
              _row(context, ParcelInfoColor.unowned, l10n.colourUnassigned),
            ],
          ),
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
