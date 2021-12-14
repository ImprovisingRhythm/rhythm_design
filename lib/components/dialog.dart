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
              effects: const [UITouchableEffect.color],
              variant: UIVariant.secondary,
              title: buttonTextConfirm ?? localizations.confirm,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
        ),
      ),
    );
  }
}

// class ConfirmDialog extends StatelessWidget {
//   const ConfirmDialog({
//     Key? key,
//     required this.text,
//     this.title,
//     this.buttonTextConfirm,
//     this.buttonTextCancel,
//     this.destructive = false,
//   }) : super(key: key);

//   final String text;
//   final String? title;
//   final String? buttonTextConfirm;
//   final String? buttonTextCancel;
//   final bool destructive;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 15),
//           if (title != null)
//             DialogTitle(title!).margin(bottom: 15, horizontal: 15),
//           Text(text).margin(bottom: 20, horizontal: 15),
//           Row(children: [
//             Button(
//               color: context.colors.fill,
//               title: buttonTextCancel ?? '取消',
//               borderRadius: BorderRadius.zero,
//               onPressed: () => Router.dismiss(false),
//             ).expanded(),
//             Button(
//               color: destructive
//                   ? context.colors.red.withOpacity(0.2)
//                   : context.colors.primary.withOpacity(0.2),
//               textColor:
//                   destructive ? context.colors.red : context.colors.primary,
//               title: buttonTextConfirm ?? '确认',
//               borderRadius: BorderRadius.zero,
//               onPressed: () => Router.dismiss(true),
//             ).expanded()
//           ]),
//         ],
//       ),
//     );
//   }
// }

// class PromptDialog extends StatefulWidget {
//   const PromptDialog({
//     this.title,
//     this.text,
//     this.placeholder,
//     this.isPassword = false,
//     this.buttonTextConfirm,
//     this.buttonTextCancel,
//     this.defaultValue,
//     this.minLines = 1,
//     this.maxLines = 1,
//     this.maxLength,
//     this.maxLengthDBCSMode = false,
//   });

//   final String? title;
//   final String? text;
//   final String? placeholder;
//   final bool isPassword;
//   final String? buttonTextConfirm;
//   final String? buttonTextCancel;
//   final String? defaultValue;
//   final int minLines;
//   final int maxLines;
//   final int? maxLength;
//   final bool maxLengthDBCSMode;

//   @override
//   _PromptDialogState createState() => _PromptDialogState();
// }

// class _PromptDialogState extends State<PromptDialog> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = TextEditingController(text: widget.defaultValue);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = context.textTheme;

//     return Dialog(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 15),
//           if (widget.title != null)
//             DialogTitle(widget.title!).margin(bottom: 15, horizontal: 15),
//           if (widget.text != null)
//             Text(
//               widget.text!,
//               style: textTheme.textStyle.small,
//               color: context.colors.secondaryLabel,
//             ).margin(
//               bottom: 20,
//               horizontal: 15,
//             ),
//           TextInput(
//             controller: _controller,
//             minLines: widget.minLines,
//             maxLines: widget.maxLines,
//             maxLength: widget.maxLength,
//             maxLengthDBCSMode: widget.maxLengthDBCSMode,
//             isPassword: widget.isPassword,
//             placeholder: widget.placeholder,
//             borderRadius: kBorderRadiusSmall,
//           ).margin(bottom: 20, horizontal: 15),
//           Row(children: [
//             Button(
//               color: context.colors.fill,
//               title: widget.buttonTextCancel ?? '取消',
//               borderRadius: BorderRadius.zero,
//               onPressed: () => Router.dismiss(),
//             ).expanded(),
//             Button(
//               color: context.colors.primary.withOpacity(0.2),
//               textColor: context.colors.primary,
//               title: widget.buttonTextConfirm ?? '确认',
//               borderRadius: BorderRadius.zero,
//               onPressed: () => Router.dismiss(_controller.text),
//             ).expanded()
//           ]),
//         ],
//       ),
//     );
//   }
// }
