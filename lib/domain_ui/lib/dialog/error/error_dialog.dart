import 'package:core_ui/dialog/base_dialog.dart';
import 'package:domain_ui/dialog/error/builder/error_dialog_builder.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends BaseDialog {
  final String message;

  ErrorDialog(super.context, {required this.message});

  @override
  WidgetBuilder get builder =>
      (context) => ErrorDialogBuilder(message: message);
}
