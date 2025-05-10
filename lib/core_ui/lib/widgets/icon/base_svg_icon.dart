import 'package:core_ui/values/base_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BaseSvgIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final Color? color;

  const BaseSvgIcon(
    this.assetName, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: size ?? IconTheme.of(context).size,
      height: size ?? IconTheme.of(context).size,
      colorFilter: ColorFilter.mode(
          color == null
              ? IconTheme.of(context).color ?? BaseColor.black
              : color!,
          BlendMode.srcIn),
    );
  }
}
