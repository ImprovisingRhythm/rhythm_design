import 'dart:ui';

import 'package:flutter/foundation.dart';

bool get hasBlurEffect {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return false;
  }
}

bool get hasSuitableHapticHardware {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return false;
  }
}

Color glassify(Color color) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return color.withOpacity(0.8);
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return color.withOpacity(0.98);
  }
}
