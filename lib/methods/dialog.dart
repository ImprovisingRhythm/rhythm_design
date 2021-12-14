import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../components/dialog.dart';
import '../transitions/dialog.dart';
import '../utils/global_navigator.dart';

Future<T?> showDialog<T>({
  required WidgetBuilder builder,
  BuildContext? context,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  context ??= GlobalNavigator.buildContext;

  return Navigator.of(context).push<T>(
    DialogModalRoute(
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
