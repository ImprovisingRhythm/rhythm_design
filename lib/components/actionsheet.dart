import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../localizations/rhythm.dart';
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
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final resolvedColor = destructive ? theme.dangerColor : textColor;

    return Touchable(
      highlightColor: theme.highlightColor,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: height ?? theme.actionSheetItemHeight,
        color: theme.transparent,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.actionSheetItemTextStyle.copyWith(color: resolvedColor),
        ),
      ),
    );
  }
}

class ActionSheet extends StatelessWidget {
  const ActionSheet({
    Key? key,
    required this.items,
    this.cancelButton = true,
  }) : super(key: key);

  final List<ActionSheetItem> items;
  final bool cancelButton;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = ThemeProvider.of(context);
    final localizations = RhythmLocalizations.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.only(bottom: mediaQuery.viewPadding.bottom),
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
        children: cancelButton
            ? [
                ...items,
                Container(height: 8, color: theme.dividerColor),
                ActionSheetItem(
                  text: localizations.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : items,
      ),
    );
  }
}
