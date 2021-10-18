import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardDismissible extends StatelessWidget {
  const KeyboardDismissible({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: child,
    );
  }
}
