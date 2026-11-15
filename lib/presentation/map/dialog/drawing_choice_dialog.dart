import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_format.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

/// Asks which of a registry parcel's real boundaries an owner goes on, when
/// the parcel has more than one (after a split, say).
///
/// [open] answers the chosen drawing, or null when the member backs out.
class DrawingChoiceDialog extends StatelessWidget {
  const DrawingChoiceDialog({super.key, required this.drawings});

  final List<DrawnParcelEntity> drawings;

  static Future<DrawnParcelEntity?> open(
    BuildContext context, {
    required List<DrawnParcelEntity> drawings,
  }) => showDialog<DrawnParcelEntity>(
    context: context,
    builder: (_) => DrawingChoiceDialog(drawings: drawings),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = ParcelInfoLocalKeys.of(context);
    final ParcelInfoFormat format = ParcelInfoFormat(l10n);
    return AlertDialog(
      title: ParcelInfoText(l10n.assignOwnerWhichDrawing),
      content: SizedBox(
        width: ParcelInfoDimens.panelMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DrawnParcelEntity drawing in drawings)
                ListTile(
                  leading: const Icon(
                    Icons.edit_location_alt_outlined,
                    color: ParcelInfoColor.drawnStroke,
                  ),
                  title: ParcelInfoText(drawing.name),
                  subtitle: ParcelInfoText(
                    format.area(drawing.outline.areaSquareMeters),
                  ),
                  onTap: () => Navigator.of(context).pop(drawing),
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
}
