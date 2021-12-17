import 'package:flutter/widgets.dart';

class GlobalNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get context {
    final context = navigatorKey.currentContext;

    if (context == null) {
      throw FlutterError('Need to attach navigatorKey first');
    }

    return context;
  }

  static NavigatorState get state {
    final state = navigatorKey.currentState;

    if (state == null) {
      throw FlutterError('Need to attach navigatorKey first');
    }

    return state;
  }

  static OverlayState get overlay {
    final overlay = state.overlay;

    if (overlay == null) {
      throw FlutterError('overlay state has not been initialized');
    }

    return overlay;
  }
}
