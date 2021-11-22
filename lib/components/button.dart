import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import 'touchable.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    this.title,
    this.child,
    this.variant = UIVariant.primary,
    this.size = UISize.md,
    this.width,
    this.height,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.textColor,
    this.backgroundColor,
    this.onPressed,
  })  : assert(child != null || title != null),
        super(key: key);

  final String? title;
  final Widget? child;
  final UIVariant variant;
  final UISize size;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final buttonSize = theme.buttonSize[size]!;
    final buttonVariant = theme.buttonVariant[variant]!;
    final _title = title;

    return Semantics(
      excludeSemantics: true,
      label: title,
      button: true,
      child: Touchable(
        haptic: true,
        scale: 0.96,
        onPressed: onPressed,
        child: Container(
          width: width ?? buttonSize.width,
          height: height ?? buttonSize.height,
          alignment: Alignment.center,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? buttonVariant.backgroundColor,
            borderRadius: shape == BoxShape.rectangle
                ? borderRadius ?? theme.borderRadius
                : null,
            shape: shape,
          ),
          child: _title != null
              ? Text(
                  _title,
                  style: TextStyle(
                    color: textColor ?? buttonVariant.textColor,
                    fontSize: buttonSize.fontSize,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

class IconButton extends StatelessWidget {
  const IconButton({
    Key? key,
    required this.label,
    required this.icon,
    this.variant = UIVariant.primary,
    this.size = UISize.md,
    this.customSize,
    this.iconColor,
    this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  final String label;
  final Icon icon;
  final UIVariant variant;
  final UISize size;
  final double? customSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final buttonSize = customSize ?? theme.buttonSize[size]!.height;
    final buttonVariant = theme.buttonVariant[variant]!;

    return Semantics(
      excludeSemantics: true,
      label: label,
      button: true,
      child: Touchable(
        highlightColor: theme.highlightColor,
        highlightShape: BoxShape.circle,
        onPressed: onPressed,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor ?? buttonVariant.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon.icon,
            size: icon.size,
            color: icon.color ?? iconColor ?? buttonVariant.textColor,
          ),
        ),
      ),
    );
  }
}
