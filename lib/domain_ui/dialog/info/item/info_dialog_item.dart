import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/domain/info/info.dart';
import 'package:parcel_atlas/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/domain_ui/widgets/text/parcel_info_text.dart';

class InfoDialogItem extends StatelessWidget {
  final Info info;

  const InfoDialogItem({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseDimens.padding.small),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Flexible(
            child: ParcelInfoText(
              info.label + CoreConstants.colon + CoreConstants.space,
              style: TextStyle(
                color: ParcelInfoColor.black,
                fontWeight: FontWeight.bold,
                fontSize: BaseDimens.font.medium,
              ),
            ),
          ),
          Flexible(
            child: ParcelInfoText(
              info.value,
              style: TextStyle(
                color: ParcelInfoColor.black,
                fontWeight: FontWeight.normal,
                fontSize: BaseDimens.font.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
