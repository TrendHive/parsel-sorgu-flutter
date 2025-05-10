import 'package:core_ui/dialog/base_dialog.dart';
import 'package:domain/info/info.dart';
import 'package:domain_ui/dialog/info/builder/info_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  WidgetBuilder get builder => (context) => InfoDialogBuilder(
        title: title,
        subTitle: subTitle,
        infoList: infoList,
        onClosePressed: () => context.pop(),
      );
}
