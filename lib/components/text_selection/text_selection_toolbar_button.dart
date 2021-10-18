import 'package:flutter/widgets.dart';

import '../../app/theme_provider.dart';
import '../touchable.dart';

const _kToolbarButtonHeight = 40.0;
const _kToolbarArrowHeight = 7.0;
const _kToolbarButtonPadding = EdgeInsets.symmetric(horizontal: 16);

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
        highlightColor: theme.white.withOpacity(0.08),
        duration: Duration.zero,
        reverseDuration: Duration.zero,
        onPressed: onPressed,
        child: Container(
          margin: const EdgeInsets.only(top: _kToolbarArrowHeight),
          padding: _kToolbarButtonPadding,
          height: _kToolbarButtonHeight,
          alignment: Alignment.center,
          color: theme.transparent,
          child: FittedBox(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
