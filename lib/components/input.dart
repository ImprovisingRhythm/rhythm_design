// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import 'text_selection/text_selection_controls.dart';

export 'package:flutter/services.dart'
    show
        TextInputType,
        TextInputAction,
        TextCapitalization,
        SmartQuotesType,
        SmartDashesType;

const int _iOSHorizontalCursorOffsetPixels = -2;

enum OverlayVisibilityMode {
  never,
  editing,
  notEditing,
  always,
}

class _InputSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _InputSelectionGestureDetectorBuilder({
    required _InputState state,
  })  : _state = state,
        super(delegate: state);

  final _InputState _state;

  @override
  void onSingleTapUp(TapUpDetails details) {
    editableText.hideToolbar();

    // Because TextSelectionGestureDetector listens to taps that happen on
    // widgets in front of it, tapping the clear button will also trigger
    // this handler. If the clear button widget recognizes the up event,
    // then do not handle it.
    if (_state._clearGlobalKey.currentContext != null) {
      final RenderBox renderBox = _state._clearGlobalKey.currentContext!
          .findRenderObject()! as RenderBox;
      final Offset localOffset =
          renderBox.globalToLocal(details.globalPosition);

      if (renderBox.hitTest(BoxHitTestResult(), position: localOffset)) {
        return;
      }
    }

    super.onSingleTapUp(details);
    _state._requestKeyboard();
    _state.widget.onTap?.call();
  }

  @override
  void onDragSelectionEnd(DragEndDetails details) {
    _state._requestKeyboard();
  }
}

class Input extends StatefulWidget {
  const Input({
    Key? key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.placeholder,
    this.placeholderStyle,
    this.prefix,
    this.prefixMode = OverlayVisibilityMode.always,
    this.suffix,
    this.suffixMode = OverlayVisibilityMode.always,
    this.clearButtonMode = OverlayVisibilityMode.never,
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    ToolbarOptions? toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.strut,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
  })  : assert(obscuringCharacter.length == 1),
        smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength > 0),
        // Assert the following instead of setting it directly to avoid surprising the user by silently changing the value they set.
        assert(
          !identical(textInputAction, TextInputAction.newline) ||
              maxLines == 1 ||
              !identical(keyboardType, TextInputType.text),
          'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.',
        ),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        toolbarOptions = toolbarOptions ??
            (obscureText
                ? const ToolbarOptions(
                    selectAll: true,
                    paste: true,
                  )
                : const ToolbarOptions(
                    copy: true,
                    cut: true,
                    selectAll: true,
                    paste: true,
                  )),
        super(key: key);

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// Controls the [BoxDecoration] of the box behind the text input.
  ///
  /// Defaults to having a rounded rectangle grey border and can be null to have
  /// no box decoration.
  final BoxDecoration? decoration;

  /// Padding around the text entry area between the [prefix] and [suffix]
  /// or the clear button when [clearButtonMode] is not never.
  final EdgeInsets padding;

  /// A lighter colored placeholder hint that appears on the first line of the
  /// text field when the text entry is empty.
  ///
  /// Defaults to having no placeholder text.
  ///
  /// The text style of the placeholder text matches that of the text field's
  /// main text entry except a lighter font weight and a grey font color.
  final String? placeholder;

  /// The style to use for the placeholder text.
  ///
  /// The [placeholderStyle] is merged with the [style] [TextStyle] when applied
  /// to the [placeholder] text. To avoid merging with [style], specify
  /// [TextStyle.inherit] as false.
  ///
  /// Defaults to the [style] property with w300 font weight and grey color.
  ///
  /// If specifically set to null, placeholder's style will be the same as [style].
  final TextStyle? placeholderStyle;

  /// An optional [Widget] to display before the text.
  final Widget? prefix;

  /// Controls the visibility of the [prefix] widget based on the state of
  /// text entry when the [prefix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [prefix] is null.
  final OverlayVisibilityMode prefixMode;

  /// An optional [Widget] to display after the text.
  final Widget? suffix;

  /// Controls the visibility of the [suffix] widget based on the state of
  /// text entry when the [suffix] argument is not null.
  ///
  /// Defaults to [OverlayVisibilityMode.always] and cannot be null.
  ///
  /// Has no effect when [suffix] is null.
  final OverlayVisibilityMode suffixMode;

  /// Show an iOS-style clear button to clear the current text entry.
  ///
  /// Can be made to appear depending on various text states of the
  /// [TextEditingController].
  ///
  /// Will only appear if no [suffix] widget is appearing.
  ///
  /// Defaults to never appearing and cannot be null.
  final OverlayVisibilityMode clearButtonMode;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  ///
  /// Also serves as a base for the [placeholder] text's style.
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// Configuration of toolbar options.
  ///
  /// If not set, select all and paste will default to be enabled. Copy and cut
  /// will be disabled if [obscureText] is true. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  final ToolbarOptions toolbarOptions;

  /// {@macro flutter.material.InputDecorator.textAlignVertical}
  final TextAlignVertical? textAlignVertical;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.obscuringCharacter}
  final String obscuringCharacter;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.services.TextInputConfiguration.smartDashesType}
  final SmartDashesType smartDashesType;

  /// {@macro flutter.services.TextInputConfiguration.smartQuotesType}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.maxLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// The maximum number of characters (Unicode scalar values) to allow in the
  /// text field.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforcement] is set to
  /// [MaxLengthEnforcement.none].
  ///
  /// The TextField enforces the length with a
  /// [LengthLimitingTextInputFormatter], which is evaluated after the supplied
  /// [inputFormatters], if any.
  ///
  /// This value must be either null or greater than zero. If set to null
  /// (the default), there is no limit to the number of characters allowed.
  ///
  /// Whitespace characters (e.g. newline, space, tab) are included in the
  /// character count.
  ///
  /// {@macro flutter.services.lengthLimitingTextInputFormatter.maxLength}
  final int? maxLength;

  /// Determines how the [maxLength] limit should be enforced.
  ///
  /// If [MaxLengthEnforcement.none] is set, additional input beyond [maxLength]
  /// will not be enforced by the limit.
  ///
  /// {@macro flutter.services.textFormatter.effectiveMaxLengthEnforcement}
  ///
  /// {@macro flutter.services.textFormatter.maxLengthEnforcement}
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// {@macro flutter.widgets.editableText.onChanged}
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  ///
  /// See also:
  ///
  ///  * [TextInputAction.next] and [TextInputAction.previous], which
  ///    automatically shift the focus to the next/previous focusable item when
  ///    the user is done editing.
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// Disables the text field when false.
  ///
  /// Text fields in disabled states have a light grey background and don't
  /// respond to touch events including the [prefix], [suffix] and the clear
  /// button.
  final bool? enabled;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius cursorRadius;

  /// The color to use when painting the cursor.
  ///
  /// Defaults to the [CupertinoThemeData.primaryColor] of the ambient theme,
  /// which itself defaults to [CupertinoColors.activeBlue] in the light theme
  /// and [CupertinoColors.activeOrange] in the dark theme.
  final Color? cursorColor;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle selectionWidthStyle;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If null, defaults to [Brightness.light].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  /// {@macro flutter.material.textfield.onTap}
  final GestureTapCallback? onTap;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// {@macro flutter.material.textfield.restorationId}
  final String? restorationId;

  /// {@macro flutter.services.TextInputConfiguration.enableIMEPersonalizedLearning}
  final bool enableIMEPersonalizedLearning;

  @override
  State<Input> createState() => _InputState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'controller', controller,
        defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
        defaultValue: null));
    properties
        .add(DiagnosticsProperty<BoxDecoration>('decoration', decoration));
    properties.add(DiagnosticsProperty<EdgeInsets>('padding', padding));
    properties.add(StringProperty('placeholder', placeholder));
    properties.add(
        DiagnosticsProperty<TextStyle>('placeholderStyle', placeholderStyle));
    properties.add(DiagnosticsProperty<OverlayVisibilityMode>(
        'prefix', prefix == null ? null : prefixMode));
    properties.add(DiagnosticsProperty<OverlayVisibilityMode>(
        'suffix', suffix == null ? null : suffixMode));
    properties.add(DiagnosticsProperty<OverlayVisibilityMode>(
        'clearButtonMode', clearButtonMode));
    properties.add(DiagnosticsProperty<TextInputType>(
        'keyboardType', keyboardType,
        defaultValue: TextInputType.text));
    properties.add(
        DiagnosticsProperty<TextStyle>('style', style, defaultValue: null));
    properties.add(
        DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false));
    properties.add(DiagnosticsProperty<String>(
        'obscuringCharacter', obscuringCharacter,
        defaultValue: '•'));
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText,
        defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('autocorrect', autocorrect,
        defaultValue: true));
    properties.add(EnumProperty<SmartDashesType>(
        'smartDashesType', smartDashesType,
        defaultValue:
            obscureText ? SmartDashesType.disabled : SmartDashesType.enabled));
    properties.add(EnumProperty<SmartQuotesType>(
        'smartQuotesType', smartQuotesType,
        defaultValue:
            obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled));
    properties.add(DiagnosticsProperty<bool>(
        'enableSuggestions', enableSuggestions,
        defaultValue: true));
    properties.add(IntProperty('maxLines', maxLines, defaultValue: 1));
    properties.add(IntProperty('minLines', minLines, defaultValue: null));
    properties.add(
        DiagnosticsProperty<bool>('expands', expands, defaultValue: false));
    properties.add(IntProperty('maxLength', maxLength, defaultValue: null));
    properties.add(EnumProperty<MaxLengthEnforcement>(
        'maxLengthEnforcement', maxLengthEnforcement,
        defaultValue: null));
    properties
        .add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 2.0));
    properties
        .add(DoubleProperty('cursorHeight', cursorHeight, defaultValue: null));
    properties.add(DiagnosticsProperty<Radius>('cursorRadius', cursorRadius,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Color>('cursorColor', cursorColor,
        defaultValue: null));
    properties.add(FlagProperty('selectionEnabled',
        value: selectionEnabled,
        defaultValue: true,
        ifFalse: 'selection disabled'));
    properties.add(DiagnosticsProperty<TextSelectionControls>(
        'selectionControls', selectionControls,
        defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollController>(
        'scrollController', scrollController,
        defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>(
        'scrollPhysics', scrollPhysics,
        defaultValue: null));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: TextAlign.start));
    properties.add(DiagnosticsProperty<TextAlignVertical>(
        'textAlignVertical', textAlignVertical,
        defaultValue: null));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(DiagnosticsProperty<bool>(
        'enableIMEPersonalizedLearning', enableIMEPersonalizedLearning,
        defaultValue: true));
  }
}

class _InputState extends State<Input>
    with RestorationMixin, AutomaticKeepAliveClientMixin<Input>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey _clearGlobalKey = GlobalKey();

  RestorableTextEditingController? _controller;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!.value;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  MaxLengthEnforcement get _effectiveMaxLengthEnforcement =>
      widget.maxLengthEnforcement ??
      LengthLimitingTextInputFormatter.getDefaultMaxLengthEnforcement();

  bool _showSelectionHandles = false;

  late _InputSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  // API for TextSelectionGestureDetectorBuilderDelegate.
  @override
  bool get forcePressEnabled => true;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.selectionEnabled;
  // End of API for TextSelectionGestureDetectorBuilderDelegate.

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _InputSelectionGestureDetectorBuilder(state: this);
    if (widget.controller == null) {
      _createLocalController();
    }
    _effectiveFocusNode.canRequestFocus = widget.enabled ?? true;
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }
    _effectiveFocusNode.canRequestFocus = widget.enabled ?? true;
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
    _controller!.value.addListener(updateKeepAlive);
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  EditableTextState get _editableText => editableTextKey.currentState!;

  void _requestKeyboard() {
    _editableText.requestKeyboard();
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    }

    // On iOS, we don't show handles when the selection is collapsed.
    if (_effectiveController.selection.isCollapsed) return false;

    if (cause == SelectionChangedCause.keyboard) return false;

    if (_effectiveController.text.isNotEmpty) return true;

    return false;
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    if (!mounted) return;
    if (cause == SelectionChangedCause.longPress) {
      _editableText.bringIntoView(selection.base);
    }

    final willShowSelectionHandles = _shouldShowSelectionHandles(cause);

    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }
  }

  @override
  bool get wantKeepAlive => _controller?.value.text.isNotEmpty == true;

  bool _shouldShowAttachment({
    required OverlayVisibilityMode attachment,
    required bool hasText,
  }) {
    switch (attachment) {
      case OverlayVisibilityMode.never:
        return false;
      case OverlayVisibilityMode.always:
        return true;
      case OverlayVisibilityMode.editing:
        return hasText;
      case OverlayVisibilityMode.notEditing:
        return !hasText;
    }
  }

  bool _showPrefixWidget(TextEditingValue text) {
    return widget.prefix != null &&
        _shouldShowAttachment(
          attachment: widget.prefixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showSuffixWidget(TextEditingValue text) {
    return widget.suffix != null &&
        _shouldShowAttachment(
          attachment: widget.suffixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showClearButton(TextEditingValue text) {
    return _shouldShowAttachment(
      attachment: widget.clearButtonMode,
      hasText: text.text.isNotEmpty,
    );
  }

  // True if any surrounding decoration widgets will be shown.
  bool get _hasDecoration {
    return widget.placeholder != null ||
        widget.clearButtonMode != OverlayVisibilityMode.never ||
        widget.prefix != null ||
        widget.suffix != null;
  }

  // Provide default behavior if widget.textAlignVertical is not set.
  // Input has top alignment by default, unless it has decoration
  // like a prefix or suffix, in which case it's aligned to the center.
  TextAlignVertical get _textAlignVertical {
    if (widget.textAlignVertical != null) {
      return widget.textAlignVertical!;
    }
    return _hasDecoration ? TextAlignVertical.center : TextAlignVertical.top;
  }

  Widget _addTextDependentAttachments(
    Widget editableText,
    TextStyle textStyle,
    TextStyle placeholderStyle,
  ) {
    final theme = ThemeProvider.of(context);

    // If there are no surrounding widgets, just return the core editable text
    // part.
    if (!_hasDecoration) {
      return editableText;
    }

    // Otherwise, listen to the current state of the text entry.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: editableText,
      builder: (BuildContext context, TextEditingValue? text, Widget? child) {
        return Row(children: <Widget>[
          // Insert a prefix at the front if the prefix visibility mode matches
          // the current text state.
          if (_showPrefixWidget(text!)) widget.prefix!,
          // In the middle part, stack the placeholder on top of the main EditableText
          // if needed.
          Expanded(
            child: Stack(
              children: <Widget>[
                if (widget.placeholder != null && text.text.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: widget.padding,
                      child: Text(
                        widget.placeholder!,
                        maxLines: widget.maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: placeholderStyle,
                        textAlign: widget.textAlign,
                      ),
                    ),
                  ),
                child!,
              ],
            ),
          ),
          // First add the explicit suffix if the suffix visibility mode matches.
          if (_showSuffixWidget(text))
            widget.suffix!
          // Otherwise, try to show a clear button if its visibility mode matches.
          else if (_showClearButton(text))
            GestureDetector(
              key: _clearGlobalKey,
              onTap: widget.enabled ?? true
                  ? () {
                      // Special handle onChanged for ClearButton
                      // Also call onChanged when the clear button is tapped.
                      final textChanged = _effectiveController.text.isNotEmpty;
                      _effectiveController.clear();

                      if (widget.onChanged != null && textChanged) {
                        widget.onChanged!(_effectiveController.text);
                      }
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.only(right: widget.padding.right),
                child: Icon(
                  EvaIcons.close,
                  size: 20.0,
                  color: theme.placeholderTextColor,
                ),
              ),
            ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    assert(debugCheckHasDirectionality(context));

    final TextEditingController controller = _effectiveController;

    TextSelectionControls? textSelectionControls = widget.selectionControls;
    VoidCallback? handleDidGainAccessibilityFocus;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        textSelectionControls ??= defaultTextSelectionControls;
        break;

      case TargetPlatform.macOS:
        textSelectionControls ??= defaultTextSelectionControls;
        handleDidGainAccessibilityFocus = () {
          // macOS automatically activated the TextField when it receives
          // accessibility focus.
          if (!_effectiveFocusNode.hasFocus &&
              _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
        break;
    }

    final bool enabled = widget.enabled ?? true;
    final Offset cursorOffset = Offset(
        _iOSHorizontalCursorOffsetPixels /
            MediaQuery.of(context).devicePixelRatio,
        0);
    final List<TextInputFormatter> formatters = <TextInputFormatter>[
      ...?widget.inputFormatters,
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(
          widget.maxLength,
          maxLengthEnforcement: _effectiveMaxLengthEnforcement,
        ),
    ];
    final theme = ThemeProvider.of(context);
    final media = MediaQuery.of(context);

    final textStyle = widget.style ?? theme.textStyle;
    final placeholderStyle =
        textStyle.merge(widget.placeholderStyle ?? theme.placeholderTextStyle);

    final keyboardAppearance =
        widget.keyboardAppearance ?? media.platformBrightness;

    final cursorColor = theme.primaryColor;
    final disabledColor = theme.primaryBackgroundColor;
    final decorationColor = widget.decoration?.color;
    final border = widget.decoration?.border;

    Border? resolvedBorder = border as Border?;

    if (border is Border) {
      BorderSide resolveBorderSide(BorderSide side) {
        return side == BorderSide.none
            ? side
            : side.copyWith(color: theme.borderColor);
      }

      resolvedBorder = border.runtimeType != Border
          ? border
          : Border(
              top: resolveBorderSide(border.top),
              left: resolveBorderSide(border.left),
              bottom: resolveBorderSide(border.bottom),
              right: resolveBorderSide(border.right),
            );
    }

    final BoxDecoration? effectiveDecoration = widget.decoration?.copyWith(
      border: resolvedBorder,
      color: enabled ? decorationColor : disabledColor,
    );

    final Color selectionColor = theme.primaryColor.withOpacity(0.2);

    final Widget paddedEditable = Padding(
      padding: widget.padding,
      child: RepaintBoundary(
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: EditableText(
            key: editableTextKey,
            controller: controller,
            readOnly: widget.readOnly,
            toolbarOptions: widget.toolbarOptions,
            showCursor: widget.showCursor,
            showSelectionHandles: _showSelectionHandles,
            focusNode: _effectiveFocusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            style: textStyle,
            strutStyle: widget.strutStyle,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            autofocus: widget.autofocus,
            obscuringCharacter: widget.obscuringCharacter,
            obscureText: widget.obscureText,
            autocorrect: widget.autocorrect,
            smartDashesType: widget.smartDashesType,
            smartQuotesType: widget.smartQuotesType,
            enableSuggestions: widget.enableSuggestions,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            expands: widget.expands,
            selectionColor: selectionColor,
            selectionControls:
                widget.selectionEnabled ? textSelectionControls : null,
            onChanged: widget.onChanged,
            onSelectionChanged: _handleSelectionChanged,
            onEditingComplete: widget.onEditingComplete,
            onSubmitted: widget.onSubmitted,
            inputFormatters: formatters,
            rendererIgnoresPointer: true,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: cursorColor,
            cursorOpacityAnimates: true,
            cursorOffset: cursorOffset,
            paintCursorAboveText: true,
            autocorrectionTextRectColor: selectionColor,
            backgroundCursorColor: theme.unselectedTextColor,
            selectionHeightStyle: widget.selectionHeightStyle,
            selectionWidthStyle: widget.selectionWidthStyle,
            scrollPadding: widget.scrollPadding,
            keyboardAppearance: keyboardAppearance,
            dragStartBehavior: widget.dragStartBehavior,
            scrollController: widget.scrollController,
            scrollPhysics: widget.scrollPhysics,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            autofillHints: widget.autofillHints,
            restorationId: 'editable',
            enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          ),
        ),
      ),
    );

    return Semantics(
      enabled: enabled,
      onTap: !enabled || widget.readOnly
          ? null
          : () {
              if (!controller.selection.isValid) {
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
              }
              _requestKeyboard();
            },
      onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          decoration: effectiveDecoration,
          color: !enabled && effectiveDecoration == null ? disabledColor : null,
          child: _selectionGestureDetectorBuilder.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Align(
              alignment: Alignment(-1.0, _textAlignVertical.y),
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: _addTextDependentAttachments(
                paddedEditable,
                textStyle,
                placeholderStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
