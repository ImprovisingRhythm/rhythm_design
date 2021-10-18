import 'package:flutter/widgets.dart';

class GlobalNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext get buildContext {
    final context = navigatorKey.currentContext;

    if (context == null) {
      throw FlutterError('Need to attach navigatorKey first');
    }

    return context;
  }
}
