import 'package:core/constants.dart';
import 'package:domain/info/info.dart';
import 'package:domain_ui/widgets/text/parcel_info_text.dart';
import 'package:flutter/material.dart';

class InfoDialogItem extends StatelessWidget {
  final Info info;

  const InfoDialogItem({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: ParcelInfoText(info.label + CoreConstants.colon)),
        Flexible(child: ParcelInfoText(info.value)),
      ],
    );
  }
}
