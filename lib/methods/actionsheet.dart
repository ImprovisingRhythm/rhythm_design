import '../components/actionsheet.dart';
import 'modal.dart';

Future<void> showActionSheet(List<ActionSheetItem> items) {
  return showBottomSheet<void>(
    builder: (context) {
      return ActionSheet(items: items);
    },
  );
}
