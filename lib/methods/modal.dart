import 'package:flutter/widgets.dart' hide PopupRoute;

import '../app/global_navigator.dart';
import '../app/theme_provider.dart';
import '../transitions/bottom_sheet.dart';
import '../transitions/fade_in.dart';

Future<T?> showModal<T>({
  required WidgetBuilder builder,
  BuildContext? context,
  bool backGestureEnabled = false,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  context ??= GlobalNavigator.context;

  return Navigator.of(context).push<T>(
    FadeInRoute(
      builder: builder,
      backGestureEnabled: backGestureEnabled,
      barrierDismissible: barrierDismissible,
      barrierColor: ThemeProvider.of(context).modalBarrierColor,
    ),
  );
}

OverlayEntry showOverlayModal<T>(WidgetBuilder builder) {
  final overlay = GlobalNavigator.overlay;
  final entry = OverlayEntry(builder: builder);
  overlay.insert(entry);
  return entry;
}

Future<T?> showBottomSheet<T>({
  required WidgetBuilder builder,
  BuildContext? context,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  context ??= GlobalNavigator.context;

  return Navigator.of(context).push<T>(
    BottomSheetRoute(
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
