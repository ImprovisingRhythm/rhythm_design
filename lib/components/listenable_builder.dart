import 'package:flutter/widgets.dart';

class ListenableBuilder<T extends Listenable> extends StatelessWidget {
  const ListenableBuilder({
    Key? key,
    required this.value,
    required this.builder,
    this.child,
  }) : super(key: key);

  final T value;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: value,
      builder: (context, child) => builder(context, value, child),
      child: child,
    );
  }
}
