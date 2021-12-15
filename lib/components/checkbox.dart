import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/ui_props.dart';
import '../utils/ui_designer.dart';
import 'touchable.dart';

class CheckBox extends StatelessWidget {
  const CheckBox({
    Key? key,
    required this.value,
    this.title,
    this.size,
    this.onChanged,
  }) : super(key: key);

  final bool value;
  final String? title;
  final double? size;
  final Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final _title = title;
    final _size = size ?? theme.checkboxSize;

    Widget builder = Container(
      decoration: BoxDecoration(
        color: value ? theme.primaryColor : theme.primaryBackgroundColor,
        shape: BoxShape.circle,
      ),
      width: _size,
      height: _size,
      alignment: Alignment.center,
      child: value
          ? Icon(
              EvaIcons.checkmark,
              size: _size - 4.0,
              color: theme.white,
            )
          : null,
    );

    if (_title != null) {
      builder = Row(
        children: spacingX(theme.spacing / 2, [
          builder,
          Text(_title, style: theme.checkboxTitleStyle),
        ]),
      );
    }

    return Touchable(
      effects: const [UITouchableEffect.haptic],
      onPressed: () => onChanged?.call(!value),
      child: builder,
    );
  }
}
