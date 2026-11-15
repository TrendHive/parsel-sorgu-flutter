import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/info/info.dart';
import 'package:parcel_atlas/presentation/core_ui/values/base_dimens.dart';
import 'package:parcel_atlas/presentation/domain_ui/dialog/info/item/info_dialog_item.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/button/parcel_info_icon_button.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/container/parcel_info_container.dart';
import 'package:parcel_atlas/presentation/domain_ui/widgets/text/parcel_info_text.dart';

class InfoDialogBuilder extends StatelessWidget {
  final String title;
  final String? subTitle;
  final List<Info>? infoList;
  final VoidCallback? onClosePressed;

  const InfoDialogBuilder({
    super.key,
    required this.title,
    this.subTitle,
    this.infoList,
    this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ParcelInfoColor.transparent,
      child: Center(
        child: ParcelInfoContainer(
          width: MediaQuery.of(context).size.width * 4 / 5,
          height: MediaQuery.of(context).size.height * 2 / 3,
          color: ParcelInfoColor.white,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BaseDimens.radius.large),
            color: ParcelInfoColor.white,
          ),
          margin: EdgeInsets.symmetric(horizontal: BaseDimens.margin.xxxLarge),
          padding: EdgeInsets.all(BaseDimens.padding.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: ParcelInfoIconButton(
                  iconData: Icons.close,
                  onPressed: onClosePressed,
                ),
              ),
              ParcelInfoText(
                title,
                style: TextStyle(
                  color: ParcelInfoColor.black,
                  fontWeight: FontWeight.bold,
                  fontSize: BaseDimens.font.large,
                ),
              ),
              Visibility(
                visible: subTitle != null,
                child: ParcelInfoText(subTitle ?? CoreConstants.empty),
              ),
              Visibility(
                visible: infoList != null,
                child: Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: infoList?.length,
                    itemBuilder: (context, index) =>
                        InfoDialogItem(info: infoList?[index] ?? Info()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
