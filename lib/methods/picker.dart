import 'package:flutter/widgets.dart';

import '../components/picker.dart';
import 'modal.dart';

Future<void> showPicker({
  required Function(int)? onSelectedItemChanged,
  required List<Widget> children,
}) {
  return showBottomSheet<void>(
    builder: (context) {
      return PickerBottomSheet(
        child: Picker(
          onSelectedItemChanged: onSelectedItemChanged,
          children: children,
        ),
      );
    },
  );
}
