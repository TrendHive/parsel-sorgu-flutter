import 'package:core/constants.dart';
import 'package:domain_ui/dialog/info/item/info_dialog_item.dart';
import 'package:domain_ui/widgets/text/parcel_info_text.dart';
import 'package:flutter/material.dart';
import 'package:domain/info/info.dart';

class InfoDialogBuilder extends StatelessWidget {
  final String title;
  final String? subTitle;
  final List<Info>? infoList;

  const InfoDialogBuilder({
    super.key,
    required this.title,
    this.subTitle,
    this.infoList,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: MediaQuery.of(context).size.height * 2 / 3,
        height: MediaQuery.of(context).size.width * 2 / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ParcelInfoText(title),
            Visibility(
              visible: subTitle != null,
              child: ParcelInfoText(subTitle ?? CoreConstants.empty),
            ),
            Visibility(
              visible: infoList != null,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: infoList?.length,
                itemBuilder: (context, index) =>
                    InfoDialogItem(info: infoList?[index] ?? Info()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
