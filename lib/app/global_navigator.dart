import 'package:flutter/widgets.dart';

typedef RouteBuilder = Widget Function(dynamic params);

enum RouteTransitionStyle { slide, fadeIn, fadeInUp }

@immutable
class PushRouteOptions {
  final RouteTransitionStyle transitionStyle;
  final Object? params;

  const PushRouteOptions({
    this.params,
    this.transitionStyle = RouteTransitionStyle.slide,
  });
}

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
      throw FlutterError('Need to attach navigatorKey first');
    }

    return overlay;
  }

  static Route? get current {
    late final Route currentRoute;

    state.popUntil((route) {
      currentRoute = route;
      return true;
    });

    return currentRoute;
  }

  static Future<T?> push<T>(
    String routeName, {
    Object? params,
    RouteTransitionStyle transitionStyle = RouteTransitionStyle.slide,
  }) async {
    final result = await state.pushNamed(
      routeName,
      arguments: PushRouteOptions(
        params: params,
        transitionStyle: transitionStyle,
      ),
    );

    return result as T?;
  }

  static Future<T> replace<T>(
    String routeName, {
    Object? params,
    RouteTransitionStyle transitionStyle = RouteTransitionStyle.slide,
  }) async {
    final result = await state.pushReplacementNamed(
      routeName,
      arguments: PushRouteOptions(
        params: params,
        transitionStyle: transitionStyle,
      ),
    );

    return result as T;
  }

  static void reset(
    String routeName, {
    Object? params,
    RouteTransitionStyle transitionStyle = RouteTransitionStyle.slide,
    bool resetCurrent = false,
  }) {
    if (!resetCurrent && current?.settings.name == routeName) {
      return;
    }

    state.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: PushRouteOptions(
        params: params,
        transitionStyle: transitionStyle,
      ),
    );
  }

  static void pop<T>([T? result]) {
    if (state.canPop()) {
      return state.pop(result);
    }
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    return state.popUntil(predicate);
  }

  static const dismiss = pop;
}
