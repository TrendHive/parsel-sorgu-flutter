import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// A small readable chip on the imagery — a parcel's number or an edge's
/// length. [accent] colours its border so it is clear which layer it names.
class MapParcelLabel extends StatelessWidget {
  const MapParcelLabel(this.text, {super.key, required this.accent});

  final String text;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ParcelInfoColor.mapLabelBackground,
          borderRadius: BorderRadius.circular(BaseDimens.radius.small),
          border: Border.all(color: accent),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseDimens.padding.xxSmall),
          child: ParcelInfoText(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ParcelInfoColor.mapLabelText,
              fontSize: BaseDimens.font.small,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
