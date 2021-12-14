import 'package:flutter/widgets.dart';

class DialogModalRoute<T> extends ModalRoute<T> {
  DialogModalRoute({
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
    return ScaleTransition(
      scale: Tween(begin: 0.95, end: 1.0).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
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
  Duration get transitionDuration => const Duration(milliseconds: 250);
}
