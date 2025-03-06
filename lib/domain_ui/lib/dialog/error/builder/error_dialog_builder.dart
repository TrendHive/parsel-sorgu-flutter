import 'package:domain_ui/values/parcel_info_color.dart';
import 'package:domain_ui/widgets/text/parcel_info_text.dart';
import 'package:flutter/material.dart';

class ErrorDialogBuilder extends StatelessWidget {
  final String message;

  const ErrorDialogBuilder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            color: ParcelInfoColor.dangerButtonLight,
          ),
          ParcelInfoText(message)
        ],
      ),
    );
  }
}
