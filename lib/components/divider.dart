import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';

class Divider extends StatelessWidget {
  const Divider({
    Key? key,
    this.height,
    this.thickness,
    this.startIndent,
    this.endIndent,
    this.color,
  })  : assert(height == null || height >= 0.0),
        assert(thickness == null || thickness >= 0.0),
        assert(startIndent == null || startIndent >= 0.0),
        assert(endIndent == null || endIndent >= 0.0),
        super(key: key);

  final double? height;
  final double? thickness;
  final double? startIndent;
  final double? endIndent;
  final Color? color;

  static BorderSide createBorderSide(
    BuildContext? context, {
    Color? color,
    double? width,
  }) {
    final effectiveColor = color ??
        (context != null ? ThemeProvider.of(context).dividerColor : null);

    final effectiveWidth = width ??
        (context != null ? ThemeProvider.of(context).dividerThickness : null) ??
        0.0;

    if (effectiveColor == null) {
      return BorderSide(width: effectiveWidth);
    }

    return BorderSide(
      color: effectiveColor,
      width: effectiveWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final height = this.height ?? theme.dividerSpacing;
    final thickness = this.thickness ?? theme.dividerThickness;
    final startIndent = this.startIndent ?? theme.dividerStartIndent;
    final endIndent = this.endIndent ?? theme.dividerEndIndent;

    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: thickness,
          margin: EdgeInsetsDirectional.only(
            start: startIndent,
            end: endIndent,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: createBorderSide(
                context,
                color: color,
                width: thickness,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({
    Key? key,
    this.width,
    this.thickness,
    this.startIndent,
    this.endIndent,
    this.color,
  })  : assert(width == null || width >= 0.0),
        assert(thickness == null || thickness >= 0.0),
        assert(startIndent == null || startIndent >= 0.0),
        assert(endIndent == null || endIndent >= 0.0),
        super(key: key);

  final double? width;
  final double? thickness;
  final double? startIndent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final width = this.width ?? theme.dividerSpacing;
    final thickness = this.thickness ?? theme.dividerThickness;
    final startIndent = this.startIndent ?? theme.dividerStartIndent;
    final endIndent = this.endIndent ?? theme.dividerEndIndent;

    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          width: thickness,
          margin: EdgeInsetsDirectional.only(
            top: startIndent,
            bottom: endIndent,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: Divider.createBorderSide(
                context,
                color: color,
                width: thickness,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
