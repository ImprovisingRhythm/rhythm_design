import '../rhythm_design.dart';

extension ContextExt on BuildContext {
  DesignToken get theme => ThemeProvider.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  void pop() {
    Navigator.of(this).pop();
  }
}
