import 'package:flutter/material.dart';

class BaseTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget child;

  const BaseTextButton({
    super.key,
    this.onPressed,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}
