import 'package:flutter/widgets.dart';

import '../components/picker.dart';
import 'modal.dart';

Future<void> showPicker({
  required Function(int)? onSelectedItemChanged,
  required List<Widget> children,
  int initialIndex = 0,
}) {
  return showBottomSheet<void>(
    builder: (context) {
      final scrollController =
          FixedExtentScrollController(initialItem: initialIndex);

      return PickerBottomSheet(
        child: Picker(
          scrollController: scrollController,
          onSelectedItemChanged: onSelectedItemChanged,
          children: children,
        ),
      );
    },
  );
}
