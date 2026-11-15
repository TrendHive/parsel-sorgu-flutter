import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// A drawing's corner: a numbered disc, big enough for a fingertip.
///
/// [number] is the corner's place in the outline, so "corner 3 is wrong" can
/// be said and found. [selected] fills it red — the one "delete corner"
/// removes; [dragging] enlarges it so it stays visible under a finger.
class MapCornerHandle extends StatelessWidget {
  const MapCornerHandle({
    super.key,
    required this.number,
    required this.selected,
    required this.dragging,
  });

  final int number;

  final bool selected;

  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging
          ? ParcelInfoDimens.draggingScale
          : ParcelInfoDimens.restScale,
      duration: kThemeAnimationDuration,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? ParcelInfoColor.handleSelected
              : ParcelInfoColor.handleFill,
          border: Border.all(
            color: ParcelInfoColor.handleBorder,
            width: ParcelInfoDimens.drawingOutline,
          ),
        ),
        child: Center(
          child: ParcelInfoText(
            '$number',
            style: TextStyle(
              fontSize: BaseDimens.font.small,
              fontWeight: FontWeight.w700,
              color: selected
                  ? ParcelInfoColor.handleFill
                  : ParcelInfoColor.mapLabelText,
            ),
          ),
        ),
      ),
    );
  }
}
