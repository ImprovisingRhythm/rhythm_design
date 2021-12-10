import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../utils/platform_features.dart';
import 'blur_box.dart';
import 'touchable.dart';

class BottomNavigationItem {
  const BottomNavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final String label;
  final Icon icon;
  final Icon? activeIcon;
}

Icon _resolveIcon(BottomNavigationItem item, bool active) {
  return active ? (item.activeIcon ?? item.icon) : item.icon;
}

class _TouchableItem extends StatelessWidget {
  const _TouchableItem({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    return Touchable(
      haptic: true,
      onPressed: onPressed,
      child: Container(
        color: theme.transparent,
        child: child,
      ),
    );
  }
}

class _IconItem extends StatelessWidget {
  const _IconItem({
    Key? key,
    required this.item,
    this.active = false,
    this.onPressed,
  }) : super(key: key);

  final BottomNavigationItem item;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final resolvedIcon = _resolveIcon(item, active);
    final resolvedColor =
        active ? theme.primaryColor : theme.unselectedTextColor;

    return Semantics(
      excludeSemantics: true,
      label: item.label,
      button: true,
      selected: active,
      child: _TouchableItem(
        onPressed: onPressed,
        child: Icon(
          resolvedIcon.icon,
          color: resolvedColor,
          size: theme.bottomNavigationIconSize,
        ),
      ),
    );
  }
}

class _IconLabelItem extends StatelessWidget {
  const _IconLabelItem({
    Key? key,
    required this.item,
    this.active = false,
    this.onPressed,
  }) : super(key: key);

  final BottomNavigationItem item;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final resolvedIcon = _resolveIcon(item, active);
    final resolvedColor =
        active ? theme.primaryColor : theme.unselectedTextColor;

    return Semantics(
      excludeSemantics: true,
      label: item.label,
      button: true,
      selected: active,
      child: _TouchableItem(
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              resolvedIcon.icon,
              color: resolvedColor,
              size: theme.bottomNavigationIconSize,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.label,
                style: theme.bottomNavigationLabelTextStyle
                    .copyWith(color: resolvedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
    required this.items,
    required this.index,
    this.label = true,
    this.onChange,
  }) : super(key: key);

  final List<BottomNavigationItem> items;
  final int index;
  final bool label;
  final Function(int newIndex)? onChange;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final mediaQuery = MediaQuery.of(context);
    final resolvedBackgroundColor =
        glassify(theme.bottomNavigationBackgroundColor);

    return Semantics(
      label: 'Bottom navigation bar',
      container: true,
      child: BlurBox(
        child: Container(
          height: theme.bottomNavigationHeight + mediaQuery.viewPadding.bottom,
          padding: EdgeInsets.only(bottom: mediaQuery.viewPadding.bottom),
          decoration: BoxDecoration(
            color: resolvedBackgroundColor,
            border: Border(
              top: BorderSide(
                width: 1,
                color: theme.borderColor,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: label
                      ? _IconLabelItem(
                          item: items[i],
                          active: i == index,
                          onPressed:
                              i == index ? null : () => onChange?.call(i),
                        )
                      : _IconItem(
                          item: items[i],
                          active: i == index,
                          onPressed:
                              i == index ? null : () => onChange?.call(i),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
