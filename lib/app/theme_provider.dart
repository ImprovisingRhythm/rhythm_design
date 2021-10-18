import 'package:flutter/widgets.dart';

import '../design/design_token.dart';

class ThemeProvider extends InheritedWidget {
  const ThemeProvider({
    Key? key,
    required Widget child,
    required this.designToken,
  }) : super(key: key, child: child);

  final DesignToken designToken;

  static DesignToken of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();

    if (provider == null) {
      throw FlutterError('ThemeProvider is not found in widget tree');
    }

    return provider.designToken;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return oldWidget.designToken != designToken;
  }
}
