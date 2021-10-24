import 'package:flutter/widgets.dart';

import '../design/design_token.dart';
import '../design/ui_props.dart';

class LightTheme extends DesignToken {
  @override
  Color get primaryColor => const Color(0xff57886C);

  @override
  Color get highlightColor => black.withOpacity(0.08);

  @override
  Color get textColor => black;

  @override
  Color get primaryBackgroundColor => white;

  @override
  Color get secondaryBackgroundColor => const Color(0xfff0f0f0);

  @override
  Color get imageBackgroundColor => const Color(0xfffafafa);

  @override
  Color get borderColor => const Color(0xfff5f5f5);

  @override
  Color get dividerColor => const Color(0xfffafafa);

  @override
  Map<UIVariant, UIVariantProps> get buttonVariant {
    return {
      UIVariant.primary: UIVariantProps(
        textColor: white,
        backgroundColor: primaryColor,
      ),
    };
  }
}
