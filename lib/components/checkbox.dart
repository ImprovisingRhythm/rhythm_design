import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import '../utils/ui_designer.dart';
import 'touchable.dart';

class CheckBox extends StatefulWidget {
  const CheckBox({
    Key? key,
    required this.value,
    this.label,
    this.onChanged,
  }) : super(key: key);

  final bool value;
  final String? label;
  final Function(bool)? onChanged;

  @override
  CheckBoxState createState() => CheckBoxState();
}

class CheckBoxState extends State<CheckBox> {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final size = theme.textStyle.fontSize ?? 16.0;
    final label = widget.label;

    Widget builder = Container(
      decoration: BoxDecoration(
        color: widget.value ? theme.primaryColor : theme.primaryBackgroundColor,
        shape: BoxShape.circle,
      ),
      width: size,
      height: size,
      alignment: Alignment.center,
      child: widget.value
          ? Icon(
              EvaIcons.checkmark,
              size: size,
              color: theme.white,
            )
          : null,
    );

    if (label != null) {
      builder = Row(
        children: spacingX(theme.spacing / 2, [
          builder,
          Text(
            label,
            style: theme.textStyle.copyWith(color: theme.secondaryTextColor),
          ),
        ]),
      );
    }

    return Touchable(
      effects: const [UITouchableEffect.haptic],
      onPressed: () => widget.onChanged?.call(!widget.value),
      child: builder,
    );
  }
}
