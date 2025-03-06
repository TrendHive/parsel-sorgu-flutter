import 'package:core/navigation/navigation_service.dart';
import 'package:flutter/material.dart';

abstract class BaseDialog {
  final BuildContext context;

  bool isShown = false;
  bool barrierDismissible = true;
  WidgetBuilder get builder;

  BaseDialog(this.context);

  void onDismiss() {
    isShown = false;
  }

  void dismiss() {
    if (isShown) {
      if (Navigator.canPop(NavigationService.navigatorKey.currentContext!)) {
        Navigator.pop(NavigationService.navigatorKey.currentContext!);
      }
    }
  }

  Future show() async {
    if (!isShown) {
      isShown = true;
      await showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      ).then((value) {
        onDismiss();
        return;
      });
    }
    return;
  }
}
