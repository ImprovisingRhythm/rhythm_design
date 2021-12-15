import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import '../utils/platform_features.dart';

const _kForwardDuration = Duration(milliseconds: 150);
const _kReverseDuration = Duration(milliseconds: 150);
const _kHighlightDuration = Duration(milliseconds: 150);
const _kReleaseDelay = Duration(milliseconds: 100);

class Touchable extends StatefulWidget {
  const Touchable({
    Key? key,
    required this.child,
    this.effects = const [],
    this.scale = 0.98,
    this.opacity = 0.9,
    this.focusColor,
    this.focusShape = BoxShape.rectangle,
    this.borderRadius = BorderRadius.zero,
    this.duration = _kForwardDuration,
    this.reverseDuration = _kReverseDuration,
    this.releaseDelay = _kReleaseDelay,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final List<UITouchableEffect> effects;
  final double scale;
  final double opacity;
  final Color? focusColor;
  final BoxShape focusShape;
  final BorderRadius borderRadius;
  final Duration duration;
  final Duration reverseDuration;
  final Duration releaseDelay;
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
  bool _clicked = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Touchable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scale != oldWidget.scale &&
        widget.effects.contains(UITouchableEffect.scale)) {
      _scale = Tween(begin: 1.0, end: widget.scale).animate(_controller);
    }

    if (widget.opacity != oldWidget.opacity &&
        widget.effects.contains(UITouchableEffect.opacity)) {
      _opacity = Tween(begin: 1.0, end: widget.opacity).animate(_controller);
    }

    if (widget.focusColor != oldWidget.focusColor &&
        widget.effects.contains(UITouchableEffect.color)) {
      _color = ColorTween(
        begin: widget.focusColor!.withOpacity(0),
        end: widget.focusColor!,
      ).animate(_controller);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (_clicked) {
      return;
    }

    _forwardingTicker = _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_clicked) {
      return;
    }

    _clicked = true;

    if (widget.effects.contains(UITouchableEffect.haptic)) {
      _releaseHapticFeedback();
    }

    Future.delayed(widget.releaseDelay, widget.onPressed);

    _forwardingTicker?.then((_) {
      if (widget.focusColor != null) {
        Future.delayed(_kHighlightDuration, () {
          if (mounted) {
            _controller.reverse().then((_) {
              _clicked = false;
            });
          }
        });
      } else {
        if (mounted) {
          _controller.reverse().then((_) {
            _clicked = false;
          });
        }
      }
    });
  }

  void _handleTapCancel() {
    if (_clicked) {
      return;
    }

    _controller.reverse();
  }

  void _handleTap() {
    if (widget.effects.contains(UITouchableEffect.haptic)) {
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

    final theme = ThemeProvider.of(context);
    final focusColor = widget.focusColor ?? theme.focusColor;

    _color ??= ColorTween(
      begin: focusColor.withOpacity(0),
      end: focusColor,
    ).animate(_controller);

    _scale ??= Tween(begin: 1.0, end: widget.scale).animate(_controller);
    _opacity ??= Tween(begin: 1.0, end: widget.opacity).animate(_controller);

    bool hasComplexGesture = false;
    Widget builder = widget.child;

    if (widget.effects.contains(UITouchableEffect.color)) {
      hasComplexGesture = true;
      builder = AnimatedBuilder(
        animation: _color!,
        builder: (context, child) {
          return DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              color: _color!.value,
              shape: widget.focusShape,
              borderRadius: widget.focusShape == BoxShape.circle
                  ? null
                  : widget.borderRadius,
            ),
            child: child,
          );
        },
        child: builder,
      );
    }

    if (widget.effects.contains(UITouchableEffect.scale)) {
      hasComplexGesture = true;
      builder = ScaleTransition(
        scale: _scale!,
        child: builder,
      );
    }

    if (widget.effects.contains(UITouchableEffect.opacity)) {
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
