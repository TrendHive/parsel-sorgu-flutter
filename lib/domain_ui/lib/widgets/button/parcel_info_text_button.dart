import 'package:core_ui/widgets/button/base_text_button.dart';
import 'package:domain_ui/widgets/text/parcel_info_text.dart';
import 'package:flutter/material.dart';

class ParcelInfoTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const ParcelInfoTextButton(
    this.text, {
    super.key,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      onPressed: onPressed,
      style: style,
      child: ParcelInfoText(text),
    );
  }
}
