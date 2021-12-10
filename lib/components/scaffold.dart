import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import 'keyboard_dismissible.dart';

class Scaffold extends StatelessWidget {
  const Scaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigation,
    this.backgroundColor,
  }) : super(key: key);

  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigation;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final _appBar = appBar;
    final _bottomNavigation = bottomNavigation;

    return KeyboardDismissible(
      child: Container(
        color: backgroundColor ?? theme.secondaryBackgroundColor,
        child: Stack(children: [
          Positioned.fill(child: body),
          if (_appBar != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _appBar,
            ),
          if (_bottomNavigation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _bottomNavigation,
            )
        ]),
      ),
    );
  }
}
