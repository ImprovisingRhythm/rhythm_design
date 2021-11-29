import 'package:flutter/widgets.dart';

import 'ui_props.dart';

abstract class DesignToken {
  /// Common colors
  Color get transparent => const Color(0x00000000);
  Color get white => const Color(0xffffffff);
  Color get black => const Color(0xff000000);

  Color get primaryColor;
  Color get highlightColor;
  Color get dangerColor => const Color(0xfffe3f43);

  Color get textColor;
  Color get secondaryTextColor => textColor.withOpacity(0.5);
  Color get placeholderTextColor => textColor.withOpacity(0.3);
  Color get unselectedTextColor => textColor.withOpacity(0.35);

  Color get primaryBackgroundColor;
  Color get secondaryBackgroundColor;
  Color get controlBackgroundColor;
  Color get imageBackgroundColor;

  Color get borderColor;
  Color get dividerColor;
  Color get modalBarrierColor => const Color(0x90000000);

  /// Common text styles
  TextStyle get textStyle {
    return TextStyle(
      inherit: false,
      fontFamily: '.SF Pro Text',
      fontSize: 17.0,
      letterSpacing: -0.41,
      color: textColor,
      decoration: TextDecoration.none,
    );
  }

  TextStyle get placeholderTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w400,
      color: placeholderTextColor,
    );
  }

  TextStyle get titleTextStyle {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    );
  }

  /// Common style props
  Radius get radius => const Radius.circular(12);
  BorderRadius get borderRadius => BorderRadius.all(radius);
  double get spacing => 16;
  EdgeInsets get padding => EdgeInsets.all(spacing);

  /// Bottom props
  Map<UIVariant, UIVariantProps> get buttonVariant;

  Map<UISize, UISizeProps> get buttonSize {
    return const {
      UISize.xs: UISizeProps(height: 38, fontSize: 14),
      UISize.sm: UISizeProps(height: 44, fontSize: 16),
      UISize.md: UISizeProps(height: 50, fontSize: 18),
      UISize.lg: UISizeProps(height: 56, fontSize: 20),
      UISize.xl: UISizeProps(height: 62, fontSize: 22),
    };
  }

  /// Text selection toolbar props
  Color get selectionToolbarTextColor => white;
  Color get selectionToolbarBackgroundColor => const Color(0xff303030);

  /// AppBar props
  double get appBarHeight => 30.0 + spacing + spacing / 1.5;
  double get appBarIconSize => 24;
  Color get appBarBackgroundColor => secondaryBackgroundColor;

  TextStyle get appBarTitleTextStyle {
    return const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
    );
  }

  /// BottomNavigation props
  double get bottomNavigationHeight => 56;
  double get bottomNavigationIconSize => 24;
  Color get bottomNavigationBackgroundColor => primaryBackgroundColor;

  TextStyle get bottomNavigationLabelTextStyle {
    return const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );
  }

  /// Actionsheet props
  double get actionSheetItemHeight => 58.0;
  Color get actionSheetBackgroundColor => primaryBackgroundColor;

  TextStyle get actionSheetItemTextStyle {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    );
  }

  /// Picker props
  double get pickerSelectionOverlayHorizontalMargin => 9.0;
  TextStyle get pickerTextStyle {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    );
  }
}
