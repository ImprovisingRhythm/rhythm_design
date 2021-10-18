import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../transitions/bottom_modal.dart';
import '../transitions/fade_in_modal.dart';
import '../utils/global_navigator.dart';

Future<T?> showModal<T>({
  required WidgetBuilder builder,
  BuildContext? context,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  context ??= GlobalNavigator.buildContext;

  return Navigator.of(context).push<T>(
    FadeInModalRoute(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: ThemeProvider.of(context).modalBarrierColor,
    ),
  );
}

Future<T?> showBottomModal<T>({
  required WidgetBuilder builder,
  BuildContext? context,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  context ??= GlobalNavigator.buildContext;

  return Navigator.of(context).push<T>(
    BottomModalRoute(
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Builder(builder: builder),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierColor: ThemeProvider.of(context).modalBarrierColor,
    ),
  );
}
