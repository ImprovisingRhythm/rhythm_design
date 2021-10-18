import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../utils/platform_features.dart';

class BlurBox extends StatelessWidget {
  const BlurBox({
    Key? key,
    required this.child,
    this.borderRadius,
  }) : super(key: key);

  final Widget child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget builder = child;

    if (hasBlurEffect) {
      builder = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: builder,
      );

      if (borderRadius == null || borderRadius == BorderRadius.zero) {
        builder = ClipRect(child: builder);
      } else {
        builder = ClipRRect(
          borderRadius: borderRadius,
          child: builder,
        );
      }

      builder = RepaintBoundary(child: builder);
    }

    return builder;
  }
}
