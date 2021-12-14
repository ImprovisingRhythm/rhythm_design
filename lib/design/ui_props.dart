import 'package:flutter/widgets.dart';

enum UISize { xs, sm, md, lg, xl }
enum UIVariant { primary, secondary, success, danger, transparent }
enum UITouchableEffect { haptic, scale, opacity, color }

class UISizeProps {
  const UISizeProps({
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
  });

  final double? width;
  final double? height;
  final double? fontSize;
  final double? iconSize;
}

class UIVariantProps {
  const UIVariantProps({
    this.textColor,
    this.backgroundColor,
  });

  final Color? textColor;
  final Color? backgroundColor;
}
