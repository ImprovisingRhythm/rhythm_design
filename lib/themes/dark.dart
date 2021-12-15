import 'package:flutter/widgets.dart';

import '../design/design_token.dart';
import '../design/ui_props.dart';

class DarkTheme extends DesignToken {
  @override
  Color get primaryColor => const Color(0xff57886C);

  @override
  Color get primaryForegroundColor => primaryColor;

  @override
  Color get textColor => white;

  @override
  Color get primaryBackgroundColor => const Color(0xff151515);

  @override
  Color get secondaryBackgroundColor => black;

  @override
  Color get controlBackgroundColor => const Color(0xff202020);

  @override
  Color get imageBackgroundColor => controlBackgroundColor;

  @override
  Color get focusColor => white.withOpacity(0.05);

  @override
  Color get borderColor => const Color(0xff181818);

  @override
  Map<UIVariant, UIVariantProps> get buttonVariant {
    return {
      UIVariant.primary: UIVariantProps(
        textColor: white,
        backgroundColor: primaryColor,
      ),
      UIVariant.secondary: UIVariantProps(
        textColor: white,
        backgroundColor: controlBackgroundColor,
      ),
      UIVariant.transparent: UIVariantProps(
        textColor: white,
        backgroundColor: transparent,
      ),
    };
  }

  @override
  Color get actionSheetBottomDividerColor => const Color(0xff181818);
}
