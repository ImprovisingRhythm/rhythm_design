import 'package:flutter/widgets.dart';

import '../components/notification.dart';
import '../utils/global_navigator.dart';

void showNotification({
  required final String title,
  required final String content,
  Duration duration = const Duration(seconds: 3),
  Function()? onPressed,
}) {
  late final OverlayEntry entry;

  entry = OverlayEntry(builder: (context) {
    return BannerNotification(
      title: title,
      content: content,
      duration: duration,
      onPressed: onPressed,
      onClosed: () => entry.remove(),
    );
  });

  GlobalNavigator.overlay.insert(entry);
}

void showToast({
  required final String text,
  final Duration duration = const Duration(seconds: 2),
  final ToastStyle style = ToastStyle.info,
}) {
  late final OverlayEntry entry;

  entry = OverlayEntry(builder: (context) {
    return ToastNotification(
      text: text,
      duration: duration,
      style: style,
      onClosed: () => entry.remove(),
    );
  });

  GlobalNavigator.overlay.insert(entry);
}
