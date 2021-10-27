import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';

double _defaultComputeHeight(double safeHeight) => safeHeight * 0.85;

class BottomSheet extends StatelessWidget {
  const BottomSheet({
    Key? key,
    required this.child,
    this.computeHeight,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  final Widget child;
  final double Function(double safeHeight)? computeHeight;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = ThemeProvider.of(context);
    final safeHeight = mediaQuery.size.height -
        mediaQuery.viewPadding.top -
        mediaQuery.viewPadding.bottom;

    final computeFn = computeHeight ?? _defaultComputeHeight;
    final resolvedHeight =
        computeFn(safeHeight) + mediaQuery.viewPadding.bottom;

    return Container(
      height: resolvedHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.primaryBackgroundColor,
        borderRadius: (borderRadius ?? theme.borderRadius).copyWith(
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: child,
    );
  }
}
