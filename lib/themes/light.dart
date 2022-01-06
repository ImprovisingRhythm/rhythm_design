import 'package:flutter/widgets.dart';

import '../design/design_token.dart';
import '../design/ui_props.dart';

class LightTheme extends DesignToken {
  @override
  Color get primaryColor => const Color(0xff57886C);

  @override
  Color get primaryForegroundColor => primaryColor;

  @override
  Color get textColor => black;

  @override
  Color get primaryBackgroundColor => white;

  @override
  Color get secondaryBackgroundColor => const Color(0xfff0f0f0);

  @override
  Color get controlBackgroundColor => const Color(0xfff5f5f5);

  @override
  Color get imageBackgroundColor => controlBackgroundColor;

  @override
  Color get focusColor => black.withOpacity(0.05);

  @override
  Color get borderColor => const Color(0xfff5f5f5);

  @override
  Map<UIVariant, UIVariantProps> get buttonVariant {
    return {
      UIVariant.primary: UIVariantProps(
        textColor: white,
        backgroundColor: primaryColor,
        focusColor: white.withOpacity(0.05),
      ),
      UIVariant.secondary: UIVariantProps(
        textColor: black,
        backgroundColor: controlBackgroundColor,
      ),
      UIVariant.transparent: UIVariantProps(
        textColor: black,
        backgroundColor: transparent,
      ),
    };
  }

  @override
  Color get actionSheetBottomDividerColor => const Color(0xfffafafa);
}
