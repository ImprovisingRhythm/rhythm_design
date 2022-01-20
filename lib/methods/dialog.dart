import 'package:flutter/widgets.dart' hide Router;

import '../app/global_navigator.dart';
import '../app/theme_provider.dart';
import '../components/dialog.dart';
import '../transitions/dialog.dart';

Future<T?> showDialog<T>({
  required WidgetBuilder builder,
  BuildContext? context,
  bool barrierDismissible = false,
  Color? barrierColor,
}) {
  context ??= GlobalNavigator.context;

  return Navigator.of(context).push<T>(
    DialogRoute(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: ThemeProvider.of(context).modalBarrierColor,
    ),
  );
}

Future<void> showAlert({
  required String text,
  String? title,
  String? buttonTextConfirm,
}) {
  return showDialog<void>(builder: (context) {
    return AlertDialog(
      text: text,
      title: title,
      buttonTextConfirm: buttonTextConfirm,
    );
  });
}

Future<bool> showConfirm({
  required String text,
  String? title,
  String? buttonTextConfirm,
  String? buttonTextCancel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(builder: (context) {
    return ConfirmDialog(
      title: title,
      text: text,
      buttonTextConfirm: buttonTextConfirm,
      buttonTextCancel: buttonTextCancel,
      destructive: destructive,
    );
  });

  return result ?? false;
}
