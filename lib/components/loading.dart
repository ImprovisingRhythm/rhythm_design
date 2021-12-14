import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import 'activity_indicator.dart';
import 'keyboard_dismissible.dart';
import 'listenable_builder.dart';

class LoadingProgressController extends ChangeNotifier {
  double _lastValue = 0;

  double _value = 0;
  double get value => _value;
  set value(double val) {
    _lastValue = _value;
    _value = val;
    notifyListeners();
  }
}

class ActivityIndicatorWithProgress extends StatelessWidget {
  const ActivityIndicatorWithProgress(this.controller, {Key? key})
      : super(key: key);

  final LoadingProgressController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder<LoadingProgressController>(
      value: controller,
      builder: (context, model, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: model._lastValue,
            end: model.value,
          ),
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
          builder: (context, value, child) {
            return ActivityIndicator.partiallyRevealed(
              radius: 15.0,
              activeColor: const Color(0xffffffff),
              progress: value,
            );
          },
        );
      },
    );
  }
}

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({Key? key, this.controller}) : super(key: key);

  final LoadingProgressController? controller;

  @override
  LoadingOverlayState createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> reverse() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final controller = widget.controller;

    return FadeTransition(
      opacity: _opacity,
      child: KeyboardDismissible(
        child: Container(
          alignment: Alignment.center,
          color: theme.modalBarrierColor,
          child: controller != null
              ? ActivityIndicatorWithProgress(controller)
              : const ActivityIndicator(
                  radius: 15.0,
                  activeColor: Color(0xffffffff),
                ),
        ),
      ),
    );
  }
}
