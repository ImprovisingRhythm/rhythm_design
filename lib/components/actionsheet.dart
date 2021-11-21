import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../localizations/framework.dart';
import 'touchable.dart';

class ActionSheetItem extends StatelessWidget {
  const ActionSheetItem({
    Key? key,
    required this.text,
    this.onPressed,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.destructive = false,
    this.last = false,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool destructive;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = ThemeProvider.of(context);
    final resolvedColor = destructive ? theme.dangerColor : textColor;

    return Touchable(
      highlightColor: theme.highlightColor,
      onPressed: onPressed,
      child: Container(
        padding: last
            ? EdgeInsets.only(bottom: mediaQuery.viewPadding.bottom)
            : EdgeInsets.zero,
        color: theme.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: height ?? theme.actionSheetItemHeight,
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style:
                theme.actionSheetItemTextStyle.copyWith(color: resolvedColor),
          ),
        ),
      ),
    );
  }
}

class ActionSheet extends StatelessWidget {
  const ActionSheet({Key? key, required this.items}) : super(key: key);

  final List<ActionSheetItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final localizations = FrameworkLocalizations.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.actionSheetBackgroundColor,
        borderRadius: theme.borderRadius.copyWith(
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...items,
          Container(height: 8, color: theme.dividerColor),
          ActionSheetItem(
            last: true,
            text: localizations.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
