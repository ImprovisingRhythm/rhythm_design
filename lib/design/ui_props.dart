import 'package:flutter/widgets.dart';

enum UIVariant { primary, secondary, success, danger, transparent }
enum UITouchableEffect { haptic, scale, opacity, color }

class UIVariantProps {
  const UIVariantProps({
    this.textColor,
    this.backgroundColor,
    this.focusColor,
  });

  final Color? textColor;
  final Color? backgroundColor;
  final Color? focusColor;
}
