import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _kDefaultIndicatorRadius = 10.0;

class ActivityIndicator extends StatefulWidget {
  /// Creates an iOS-style activity indicator that spins clockwise.
  const ActivityIndicator({
    Key? key,
    this.animating = true,
    this.radius = _kDefaultIndicatorRadius,
    this.activeColor,
  })  : assert(radius > 0.0),
        progress = 1.0,
        super(key: key);

  /// Creates a non-animated iOS-style activity indicator that displays
  /// a partial count of ticks based on the value of [progress].
  ///
  /// When provided, the value of [progress] must be between 0.0 (zero ticks
  /// will be shown) and 1.0 (all ticks will be shown) inclusive. Defaults
  /// to 1.0.
  const ActivityIndicator.partiallyRevealed({
    Key? key,
    this.radius = _kDefaultIndicatorRadius,
    this.progress = 1.0,
    this.activeColor,
  })  : assert(radius > 0.0),
        assert(progress >= 0.0),
        assert(progress <= 1.0),
        animating = false,
        super(key: key);

  /// Whether the activity indicator is running its animation.
  ///
  /// Defaults to true.
  final bool animating;

  /// Radius of the spinner widget.
  ///
  /// Defaults to 10px. Must be positive and cannot be null.
  final double radius;

  /// Determines the percentage of spinner ticks that will be shown. Typical usage would
  /// display all ticks, however, this allows for more fine-grained control such as
  /// during pull-to-refresh when the drag-down action shows one tick at a time as
  /// the user continues to drag down.
  ///
  /// Defaults to 1.0. Must be between 0.0 and 1.0 inclusive, and cannot be null.
  final double progress;

  final Color? activeColor;

  @override
  State<ActivityIndicator> createState() => _ActivityIndicatorState();
}

class _ActivityIndicatorState extends State<ActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.animating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animating != oldWidget.animating) {
      if (widget.animating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      height: widget.radius * 2,
      width: widget.radius * 2,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ActivityIndicatorPainter(
            position: _controller,
            activeColor: widget.activeColor ??
                (mediaQuery.platformBrightness == Brightness.light
                    ? const Color(0xFF3C3C44)
                    : const Color(0xFFEBEBF5)),
            radius: widget.radius,
            progress: widget.progress,
          ),
        ),
      ),
    );
  }
}

const _kTwoPI = math.pi * 2.0;
const _kAlphaValues = <int>[47, 47, 72, 97, 122, 147, 167, 187, 207];

class _ActivityIndicatorPainter extends CustomPainter {
  _ActivityIndicatorPainter({
    required this.position,
    required this.activeColor,
    required this.radius,
    required this.progress,
  }) : super(repaint: position);

  final Animation<double> position;
  final Color activeColor;
  final double radius;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final tickCount = _kAlphaValues.length;

    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);

    final activeTick = (tickCount * position.value).floor();

    for (int i = 0; i < tickCount * progress; ++i) {
      final t = (i - activeTick) % tickCount;
      final offset = Offset(-radius / 2.0, -radius / 2.0);

      paint.color = activeColor.withAlpha(_kAlphaValues[t]);

      canvas
        ..drawCircle(offset, radius / 7, paint)
        ..rotate(_kTwoPI / tickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ActivityIndicatorPainter oldPainter) {
    return oldPainter.position != position ||
        oldPainter.activeColor != activeColor ||
        oldPainter.progress != progress;
  }
}
