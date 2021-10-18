import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import 'touchable.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.title,
    this.variant = UIVariant.primary,
    this.size = UISize.md,
    this.padding,
    this.borderRadius,
    this.textColor,
    this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  final String title;
  final UIVariant variant;
  final UISize size;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final buttonSize = theme.buttonSize[size]!;
    final buttonVariant = theme.buttonVariant[variant]!;

    return Semantics(
      excludeSemantics: true,
      label: title,
      button: true,
      child: Touchable(
        haptic: true,
        scale: 0.98,
        onPressed: onPressed,
        child: Container(
          height: buttonSize.height,
          alignment: Alignment.center,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? buttonVariant.backgroundColor,
            borderRadius: borderRadius ?? theme.borderRadius,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: textColor ?? buttonVariant.textColor,
              fontSize: buttonSize.fontSize,
            ),
          ),
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
    this.iconColor,
    this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  final String label;
  final Icon icon;
  final UIVariant variant;
  final UISize size;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final buttonSize = theme.buttonSize[size]!;
    final buttonVariant = theme.buttonVariant[variant]!;

    return Semantics(
      excludeSemantics: true,
      label: label,
      button: true,
      child: Touchable(
        haptic: true,
        scale: 0.98,
        onPressed: onPressed,
        child: Container(
          width: buttonSize.width,
          height: buttonSize.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor ?? buttonVariant.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon.icon,
            size: 24,
            color: iconColor ?? buttonVariant.textColor,
          ),
        ),
      ),
    );
  }
}
