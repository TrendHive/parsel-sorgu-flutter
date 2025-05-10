import 'package:core_ui/widgets/button/base_icon_button.dart';
import 'package:core_ui/widgets/icon/base_svg_icon.dart';
import 'package:flutter/material.dart';

class ParcelInfoIconButton extends StatelessWidget {
  final IconData? iconData;
  final String? svgAsset;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? iconSize;

  const ParcelInfoIconButton({
    super.key,
    this.iconData,
    this.svgAsset,
    this.onPressed,
    this.padding,
    this.color,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      icon: svgAsset != null
          ? BaseSvgIcon(
              svgAsset!,
              color: color,
            )
          : Icon(iconData),
      onPressed: onPressed,
      padding: padding,
      color: color,
      iconSize: iconSize,
    );
  }
}
