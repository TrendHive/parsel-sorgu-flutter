import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Round avatars over a parcel on the map, one per holder: their initials
/// on their colour. At most [ParcelInfoDimens.maxAvatars] are shown; the
/// rest are counted in a last "+n" circle.
class MapOwnerAvatars extends StatelessWidget {
  const MapOwnerAvatars({super.key, required this.holders});

  final List<({String initials, Color colour})> holders;

  @override
  Widget build(BuildContext context) {
    final int hidden = holders.length - ParcelInfoDimens.maxAvatars;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (final ({String initials, Color colour}) holder in holders.take(
          ParcelInfoDimens.maxAvatars,
        ))
          _circle(holder.initials, holder.colour),
        if (hidden > CoreConstants.zero)
          _circle(
            '${CoreConstants.plus}$hidden',
            ParcelInfoColor.sharedBranches,
          ),
      ],
    );
  }

  Widget _circle(String text, Color colour) => Container(
    width: ParcelInfoDimens.avatar,
    height: ParcelInfoDimens.avatar,
    margin: EdgeInsets.symmetric(horizontal: BaseDimens.margin.xxSmall),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: colour,
      shape: BoxShape.circle,
      border: Border.all(color: ParcelInfoColor.white),
    ),
    child: ParcelInfoText(
      text,
      maxLines: 1,
      style: TextStyle(
        color: ParcelInfoColor.white,
        fontSize: BaseDimens.font.small,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
