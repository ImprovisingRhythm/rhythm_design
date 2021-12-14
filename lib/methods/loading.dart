import 'dart:async';

import 'package:flutter/widgets.dart';

import '../components/loading.dart';
import 'modal.dart';

Future<T> handleLoading<T>(
  FutureOr<T> Function() cb, {
  LoadingProgressController? controller,
}) async {
  final key = GlobalKey<LoadingOverlayState>();
  final entry = showOverlayModal(
    (_) => LoadingOverlay(
      key: key,
      controller: controller,
    ),
  );

  try {
    final result = await cb();
    return result;
  } catch (error) {
    rethrow;
  } finally {
    await key.currentState?.reverse();
    entry.remove();
  }
}
