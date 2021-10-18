import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import 'blur_box.dart';

class Card extends StatelessWidget {
  const Card({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.width,
    this.height,
    this.blur = false,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final resolvedPadding = padding ?? theme.padding;
    final resolvedBorderRadius = borderRadius ?? theme.borderRadius;
    final resolvedBackgroundColor =
        backgroundColor ?? theme.primaryBackgroundColor;

    Widget builder = Container(
      padding: resolvedPadding,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: resolvedBorderRadius,
      ),
      child: child,
    );

    if (blur) {
      builder = BlurBox(
        borderRadius: resolvedBorderRadius,
        child: builder,
      );
    }

    return builder;
  }
}
