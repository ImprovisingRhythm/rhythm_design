import 'package:flutter/widgets.dart';

import '../app/global_navigator.dart';
import '../components/notification.dart';

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

void showSuccessToast({
  required final String text,
  final Duration duration = const Duration(seconds: 2),
}) {
  showToast(
    text: text,
    duration: duration,
    style: ToastStyle.success,
  );
}

void showErrorToast({
  required final String text,
  final Duration duration = const Duration(seconds: 2),
}) {
  showToast(
    text: text,
    duration: duration,
    style: ToastStyle.error,
  );
}
