import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core_ui/dialog/base_dialog.dart';
import 'package:parcel_atlas/domain_ui/dialog/error/builder/error_dialog_builder.dart';

class ErrorDialog extends BaseDialog {
  final String message;

  ErrorDialog(super.context, {required this.message});

  @override
  WidgetBuilder get builder =>
      (context) => ErrorDialogBuilder(message: message);
}
