import 'package:flutter/widgets.dart';

import '../../app/theme_provider.dart';
import '../../design/ui_props.dart';
import '../touchable.dart';

const _kToolbarButtonHeight = 40.0;
const _kToolbarButtonPadding = EdgeInsets.symmetric(horizontal: 18.0);

class TextSelectionToolbarButton extends StatelessWidget {
  const TextSelectionToolbarButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    return UnconstrainedBox(
      child: Touchable(
        effects: const [UITouchableEffect.color],
        focusColor: theme.white.withOpacity(0.05),
        onPressed: onPressed,
        child: Container(
          alignment: Alignment.center,
          height: _kToolbarButtonHeight,
          padding: _kToolbarButtonPadding,
          color: theme.transparent,
          child: FittedBox(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.15,
                color: onPressed != null
                    ? theme.selectionToolbarTextColor
                    : theme.selectionToolbarTextColor.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
