import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

/// The middle of a drawing's edge: its live [length], and a "+" that puts a
/// new corner there ([onInsert]) — the way to bend a straight edge to follow
/// a wall.
class MapEdgeChip extends StatelessWidget {
  const MapEdgeChip({super.key, required this.length, required this.onInsert});

  final String length;

  final VoidCallback onInsert;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: ParcelInfoColor.edgeHandleFill,
        shape: const StadiumBorder(
          side: BorderSide(color: ParcelInfoColor.handleBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onInsert,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: BaseDimens.padding.small,
              vertical: BaseDimens.padding.xxxxSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.add,
                  size: BaseDimens.size.xxSmall,
                  color: ParcelInfoColor.handleBorder,
                ),
                ParcelInfoText(
                  length,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: BaseDimens.font.small,
                    fontWeight: FontWeight.w600,
                    color: ParcelInfoColor.mapLabelText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
