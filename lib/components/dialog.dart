import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import '../localizations/framework.dart';
import '../utils/ui_designer.dart';
import 'button.dart';
import 'keyboard_dismissible.dart';

const kDialogMaxWidth = 500.0;

class Dialog extends StatelessWidget {
  const Dialog({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Align(
      alignment: Alignment.center,
      child: AnimatedPadding(
        padding: EdgeInsets.symmetric(horizontal: theme.spacing).copyWith(
          bottom: mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom / 2,
        ),
        duration: const Duration(milliseconds: 250),
        child: KeyboardDismissible(
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackgroundColor,
              borderRadius: theme.borderRadius,
            ),
            clipBehavior: Clip.antiAlias,
            constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AlertDialog extends StatelessWidget {
  const AlertDialog({
    Key? key,
    required this.text,
    this.title,
    this.buttonTextConfirm,
  }) : super(key: key);

  final String text;
  final String? title;
  final String? buttonTextConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final localizations = FrameworkLocalizations.of(context);

    return Dialog(
      child: Padding(
        padding: theme.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: spacingY(theme.spacing, [
            if (title != null) Text(title!, style: theme.dialogTitleStyle),
            Text(text),
            Button(
              variant: UIVariant.secondary,
              title: buttonTextConfirm ?? localizations.ok,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
        ),
      ),
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    required this.text,
    this.title,
    this.buttonTextConfirm,
    this.buttonTextCancel,
    this.destructive = false,
  }) : super(key: key);

  final String text;
  final String? title;
  final String? buttonTextConfirm;
  final String? buttonTextCancel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final localizations = FrameworkLocalizations.of(context);

    return Dialog(
      child: Padding(
        padding: theme.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: spacingY(theme.spacing, [
            if (title != null) Text(title!, style: theme.dialogTitleStyle),
            Text(text),
            Row(
              children: spacingX(theme.spacing, [
                Expanded(
                  child: Button(
                    variant: UIVariant.secondary,
                    title: buttonTextCancel ?? localizations.cancel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                Expanded(
                  child: Button(
                    variant: UIVariant.secondary,
                    title: buttonTextConfirm ?? localizations.confirm,
                    textColor: destructive ? theme.dangerColor : null,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
