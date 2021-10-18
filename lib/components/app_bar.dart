import 'dart:ui';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../utils/platform_features.dart';
import 'blur_box.dart';
import 'touchable.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    return Text(
      title,
      style: theme.appBarTitleTextStyle,
    );
  }
}

class AppBarButton extends StatelessWidget {
  const AppBarButton({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  final Icon icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    return Touchable(
      highlightColor: theme.highlightColor,
      highlightShape: BoxShape.circle,
      onPressed: onPressed,
      child: Container(
        width: theme.appBarHeight,
        height: theme.appBarHeight,
        alignment: Alignment.center,
        color: theme.transparent,
        child: Icon(
          icon.icon,
          color: theme.textColor,
          size: theme.appBarIconSize,
        ),
      ),
    );
  }
}

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBarButton(
      icon: const Icon(EvaIcons.arrowIosBack),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({
    Key? key,
    required this.items,
    this.backgroundColor,
  }) : super(key: key);

  final List<Widget> items;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = ThemeProvider.of(context);
    final appBarHeight = theme.appBarHeight + mediaQuery.viewPadding.top;
    final resolvedBackgroundColor =
        backgroundColor ?? theme.appBarBackgroundColor;

    return BlurBox(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: appBarHeight,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: glassify(resolvedBackgroundColor),
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: theme.borderColor,
            ),
          ),
        ),
        child: SizedBox(
          height: theme.appBarHeight,
          child: Row(children: items),
        ),
      ),
    );
  }
}
