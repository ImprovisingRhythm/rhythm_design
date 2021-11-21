import 'dart:ui';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../utils/platform_features.dart';
import 'card.dart';
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
        margin: EdgeInsets.symmetric(horizontal: theme.spacing / 2),
        width: theme.appBarHeight - theme.spacing,
        height: theme.appBarHeight - theme.spacing,
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

    final resolvedAppBarHeight =
        theme.appBarHeight + mediaQuery.viewPadding.top;

    final resolvedBackgroundColor =
        backgroundColor ?? theme.appBarBackgroundColor;

    return Card(
      padding: EdgeInsets.only(top: mediaQuery.viewPadding.top),
      height: resolvedAppBarHeight,
      backgroundColor: glassify(resolvedBackgroundColor),
      borderRadius: BorderRadius.zero,
      blur: true,
      child: Row(children: items),
    );
  }
}
