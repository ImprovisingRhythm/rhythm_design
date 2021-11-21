import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../design/design_token.dart';

extension ContextExt on BuildContext {
  DesignToken get theme => ThemeProvider.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  T getParams<T>() {
    return ModalRoute.of(this)!.settings.arguments as T;
  }
}
