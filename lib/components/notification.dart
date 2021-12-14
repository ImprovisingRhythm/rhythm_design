import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import '../utils/ui_designer.dart';
import 'null_widget.dart';
import 'touchable.dart';

class BannerNotification extends StatefulWidget {
  const BannerNotification({
    Key? key,
    required this.title,
    required this.content,
    this.duration = const Duration(seconds: 3),
    this.onPressed,
    this.onClosed,
  }) : super(key: key);

  final String title;
  final String content;
  final Duration duration;
  final Function()? onPressed;
  final Function()? onClosed;

  @override
  _BannerNotificationState createState() => _BannerNotificationState();
}

class _BannerNotificationState extends State<BannerNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;

  bool _discarded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _position = Tween<Offset>(
      begin: const Offset(0.0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (!_discarded) {
        await _controller.reverse();
      }

      widget.onClosed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = ThemeProvider.of(context);
    final mediaQuery = MediaQuery.of(context);

    if (_discarded) {
      return const NullWidget();
    }

    return SlideTransition(
      position: _position,
      child: Align(
        alignment: Alignment.topCenter,
        child: Dismissible(
          key: const Key('slideUpNotification'),
          direction: DismissDirection.up,
          dismissThresholds: const {DismissDirection.up: 0.1},
          dragStartBehavior: DragStartBehavior.down,
          onDismissed: (_) => setState(() => _discarded = true),
          child: Touchable(
            effects: const [UITouchableEffect.haptic],
            onPressed: () {
              _controller
                  .reverse()
                  .then((_) => setState(() => _discarded = true));
              widget.onPressed?.call();
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: theme.primaryBackgroundColor),
              padding: const EdgeInsets.all(15)
                  .copyWith(top: 15 + mediaQuery.viewPadding.top),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: spacingY(theme.spacing / 2, [
                  Row(
                    children: spacingX(theme.spacing / 2, [
                      Icon(
                        EvaIcons.bell,
                        size: 15,
                        color: theme.primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textStyle,
                        ),
                      ),
                    ]),
                  ),
                  Text(
                    widget.content,
                    style: theme.textStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ToastStyle { info, success, error }

class ToastNotification extends StatefulWidget {
  const ToastNotification({
    Key? key,
    required this.text,
    this.duration = const Duration(seconds: 2),
    this.style = ToastStyle.info,
    this.onClosed,
  }) : super(key: key);

  final String text;
  final Duration duration;
  final ToastStyle style;
  final Function()? onClosed;

  @override
  _ToastNotificationState createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;

  bool _discarded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _position = Tween<Offset>(
      begin: const Offset(0.0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );

    _controller.forward();

    Future.delayed(widget.duration, () async {
      await _controller.reverse();
      widget.onClosed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = ThemeProvider.of(context);
    final mediaQuery = MediaQuery.of(context);

    final colorMap = {
      ToastStyle.info: theme.overlayColor,
      ToastStyle.success: theme.successColor,
      ToastStyle.error: theme.dangerColor,
    };

    if (_discarded) {
      return const NullWidget();
    }

    return SlideTransition(
      position: _position,
      child: Align(
        alignment: Alignment.topCenter,
        child: Dismissible(
          key: const Key('slideUpToast'),
          direction: DismissDirection.up,
          dismissThresholds: const {DismissDirection.up: 0.1},
          dragStartBehavior: DragStartBehavior.down,
          onDismissed: (_) => setState(() => _discarded = true),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: colorMap[widget.style]),
            padding: const EdgeInsets.all(15)
                .copyWith(top: 15 + mediaQuery.viewPadding.top),
            child: Text(
              widget.text,
              style: theme.textStyle.copyWith(color: theme.white),
            ),
          ),
        ),
      ),
    );
  }
}
