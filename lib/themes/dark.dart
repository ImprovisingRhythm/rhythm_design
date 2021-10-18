import 'package:flutter/widgets.dart';

import '../design/design_token.dart';
import '../design/ui_props.dart';

class DarkTheme extends DesignToken {
  @override
  Color get primaryColor => const Color(0xff57886C);

  @override
  Color get highlightColor => white.withOpacity(0.08);

  @override
  Color get textColor => white;

  @override
  Color get primaryBackgroundColor => const Color(0xff151515);

  @override
  Color get secondaryBackgroundColor => black;

  @override
  Color get borderColor => const Color(0xff181818);

  @override
  Color get dividerColor => const Color(0xff181818);

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
