import 'package:flutter/material.dart';

class BaseIconButton extends StatelessWidget {
  final _IconButtonVariant _variant;
  final Widget icon;
  final VoidCallback? onPressed;
  final AlignmentGeometry? alignment;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final ButtonStyle? style;

  const BaseIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.alignment,
    this.iconSize,
    this.padding,
    this.color,
    this.disabledColor,
    this.style,
  }) : _variant = _IconButtonVariant.standard;

  const BaseIconButton.filled({
    super.key,
    required this.icon,
    this.onPressed,
    this.alignment,
    this.iconSize,
    this.padding,
    this.color,
    this.disabledColor,
    this.style,
  }) : _variant = _IconButtonVariant.filled;

  const BaseIconButton.filledTonal({
    super.key,
    required this.icon,
    this.onPressed,
    this.alignment,
    this.iconSize,
    this.padding,
    this.color,
    this.disabledColor,
    this.style,
  }) : _variant = _IconButtonVariant.filledTonal;

  const BaseIconButton.outlined({
    super.key,
    required this.icon,
    this.onPressed,
    this.alignment,
    this.iconSize,
    this.padding,
    this.color,
    this.disabledColor,
    this.style,
  }) : _variant = _IconButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _IconButtonVariant.standard:
        return IconButton(
          onPressed: onPressed,
          icon: icon,
          alignment: alignment,
          iconSize: iconSize,
          padding: padding,
          color: color,
          disabledColor: disabledColor,
          style: style,
        );
      case _IconButtonVariant.filled:
        return IconButton.filled(
          onPressed: onPressed,
          icon: icon,
          alignment: alignment,
          iconSize: iconSize,
          padding: padding,
          color: color,
          disabledColor: disabledColor,
          style: style,
        );
      case _IconButtonVariant.filledTonal:
        return IconButton.filledTonal(
          onPressed: onPressed,
          icon: icon,
          alignment: alignment,
          iconSize: iconSize,
          padding: padding,
          color: color,
          disabledColor: disabledColor,
          style: style,
        );
      case _IconButtonVariant.outlined:
        return IconButton.outlined(
          onPressed: onPressed,
          icon: icon,
          alignment: alignment,
          iconSize: iconSize,
          padding: padding,
          color: color,
          disabledColor: disabledColor,
          style: style,
        );
    }
  }
}

enum _IconButtonVariant { standard, filled, filledTonal, outlined }
