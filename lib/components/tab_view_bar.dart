import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../utils/platform_features.dart';
import 'tab_view.dart';

class TabViewBar extends StatefulWidget {
  const TabViewBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.padding,
  }) : super(key: key);

  final List<String> tabs;
  final TabController controller;
  final EdgeInsets? padding;

  @override
  TabViewBarState createState() => TabViewBarState();
}

class TabViewBarState extends State<TabViewBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.controller.index;

    widget.controller.addListener(_listener);
    widget.controller.animation?.addListener(_animationListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    widget.controller.animation?.removeListener(_animationListener);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TabViewBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      oldWidget.controller.animation?.removeListener(_animationListener);
    }
  }

  void _listener() {
    if (!mounted) return;
    if (_currentIndex != widget.controller.index) {
      setState(() {
        _currentIndex = widget.controller.index;
      });
    }
  }

  void _animationListener() {
    if (!mounted) return;
    if (widget.controller.indexIsChanging) return;

    final offset = widget.controller.offset;

    if (offset > 0.5) {
      setState(() {
        _currentIndex = widget.controller.index + 1;
      });
    } else if (offset < -0.5) {
      setState(() {
        _currentIndex = widget.controller.index - 1;
      });
    } else if (offset != 0) {
      setState(() {
        _currentIndex = widget.controller.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Row(
        children: [
          for (int index = 0; index < widget.tabs.length; index++)
            Padding(
              padding: EdgeInsets.only(right: theme.spacing),
              child: GestureDetector(
                onTap: index != _currentIndex
                    ? () {
                        if (hasSuitableHapticHardware) {
                          HapticFeedback.lightImpact();
                        }

                        widget.controller.animateTo(index);
                      }
                    : null,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.ease,
                  style: theme.textStyle
                      .copyWith(inherit: false)
                      .merge(theme.titleTextStyle)
                      .copyWith(
                        color: index != _currentIndex
                            ? theme.unselectedTextColor
                            : null,
                      ),
                  child: FittedBox(child: Text(widget.tabs[index])),
                ),
              ),
            )
        ],
      ),
    );
  }
}
