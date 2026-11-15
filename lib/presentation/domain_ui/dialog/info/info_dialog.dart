import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/domain/info/info.dart';
import 'package:parcel_atlas/presentation/core_ui/dialog/base_dialog.dart';
import 'package:parcel_atlas/presentation/domain_ui/dialog/info/builder/info_dialog_builder.dart';

class InfoDialog extends BaseDialog {
  final String title;
  final String? subTitle;
  final List<Info>? infoList;

  InfoDialog(
    super.context, {
    required this.title,
    this.subTitle,
    this.infoList,
  });

  @override
  WidgetBuilder get builder =>
      (context) => InfoDialogBuilder(
        title: title,
        subTitle: subTitle,
        infoList: infoList,
        onClosePressed: () => context.pop(),
      );
}
