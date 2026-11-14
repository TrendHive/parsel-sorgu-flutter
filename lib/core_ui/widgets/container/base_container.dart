import 'package:flutter/widgets.dart';

class BaseContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? child;

  const BaseContainer({
    super.key,
    this.width,
    this.height,
    this.color,
    this.decoration,
    this.padding,
    this.margin,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
