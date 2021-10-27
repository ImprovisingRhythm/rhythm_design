import 'package:flutter/widgets.dart';

class BottomSheetRoute<T> extends PageRoute<T> {
  BottomSheetRoute({
    RouteSettings? settings,
    required this.builder,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
  }) : super(settings: settings);

  final WidgetBuilder builder;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  bool get opaque => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.ease,
        reverseCurve: Curves.ease,
      )),
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}
