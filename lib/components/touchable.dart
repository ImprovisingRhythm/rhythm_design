import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../utils/platform_features.dart';

const _kForwardDuration = Duration(milliseconds: 150);
const _kReverseDuration = Duration(milliseconds: 150);
const _kReleaseDelay = Duration(milliseconds: 100);

class Touchable extends StatefulWidget {
  const Touchable({
    Key? key,
    required this.child,
    this.haptic = false,
    this.scale,
    this.opacity,
    this.highlightColor,
    this.highlightShape = BoxShape.rectangle,
    this.duration = _kForwardDuration,
    this.reverseDuration = _kReverseDuration,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final bool haptic;
  final double? scale;
  final double? opacity;
  final Color? highlightColor;
  final BoxShape highlightShape;
  final Duration duration;
  final Duration reverseDuration;
  final VoidCallback? onPressed;

  @override
  TouchableState createState() => TouchableState();
}

class TouchableState extends State<Touchable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Animation<Color?>? _color;
  Animation<double>? _scale;
  Animation<double>? _opacity;

  TickerFuture? _forwardingTicker;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );

    if (widget.highlightColor != null) {
      _color = ColorTween(
        begin: widget.highlightColor!.withOpacity(0),
        end: widget.highlightColor!,
      ).animate(_controller);
    }

    if (widget.scale != null) {
      _scale = Tween(begin: 1.0, end: widget.scale).animate(_controller);
    }

    if (widget.opacity != null) {
      _opacity = Tween(begin: 1.0, end: widget.opacity).animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Touchable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scale != oldWidget.scale && widget.scale != null) {
      _scale = Tween(begin: 1.0, end: widget.scale).animate(_controller);
    }

    if (widget.opacity != oldWidget.opacity && widget.opacity != null) {
      _opacity = Tween(begin: 1.0, end: widget.opacity).animate(_controller);
    }

    if (widget.highlightColor != oldWidget.highlightColor) {
      _color = ColorTween(
        begin: widget.highlightColor!.withOpacity(0),
        end: widget.highlightColor!,
      ).animate(_controller);
    }
  }

  Future<void> _handleTapDown(TapDownDetails details) async {
    _forwardingTicker = _controller.forward();
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (widget.haptic) {
      _releaseHapticFeedback();
    }

    Future.delayed(_kReleaseDelay, widget.onPressed);

    await _forwardingTicker;
    await _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.haptic) {
      _releaseHapticFeedback();
    }

    widget.onPressed?.call();
  }

  void _releaseHapticFeedback() {
    if (hasSuitableHapticHardware) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onPressed == null) {
      return widget.child;
    }

    bool hasComplexGesture = false;
    Widget builder = widget.child;

    if (_color != null) {
      hasComplexGesture = true;
      builder = AnimatedBuilder(
        animation: _color!,
        builder: (context, child) {
          return DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              color: _color!.value,
              shape: widget.highlightShape,
            ),
            child: child,
          );
        },
        child: builder,
      );
    }

    if (_scale != null) {
      hasComplexGesture = true;
      builder = ScaleTransition(
        scale: _scale!,
        child: builder,
      );
    }

    if (_opacity != null) {
      hasComplexGesture = true;
      builder = FadeTransition(
        opacity: _opacity!,
        child: builder,
      );
    }

    if (!hasComplexGesture) {
      return GestureDetector(
        onTap: _handleTap,
        child: builder,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: builder,
    );
  }
}
