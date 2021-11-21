import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../app/theme_provider.dart';
import 'text_selection_toolbar_button.dart';

const _kToolbarHeight = 47.0;
const _kToolbarContentDistance = 8.0;
const _kToolbarScreenPadding = 8.0;
const _kToolbarArrowSize = Size(14.0, 7.0);
const _kToolbarBorderRadius = Radius.circular(12.0);

/// The type for a Function that builds a toolbar's container with the given
/// child.
///
/// The anchor is provided in global coordinates.
///
/// See also:
///
///   * [TextSelectionToolbar.toolbarBuilder], which is of this type.
///   * [TextTextSelectionToolbar.toolbarBuilder], which is similar, but for an
///     Material-style toolbar.
typedef ToolbarBuilder = Widget Function(
  BuildContext context,
  Offset anchor,
  bool isAbove,
  Widget child,
);

/// An iOS-style text selection toolbar.
///
/// Typically displays buttons for text manipulation, e.g. copying and pasting
/// text.
///
/// Tries to position itself above [anchorAbove], but if it doesn't fit, then
/// it positions itself below [anchorBelow].
///
/// If any children don't fit in the menu, an overflow menu will automatically
/// be created.
///
/// See also:
///
///  * [TextSelectionControls.buildToolbar], where this is used by default to
///    build an iOS-style toolbar.
///  * [TextSelectionToolbar], which is similar, but builds an Android-style
///    toolbar.
class TextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of TextSelectionToolbar.
  const TextSelectionToolbar({
    Key? key,
    required this.anchorAbove,
    required this.anchorBelow,
    required this.children,
    this.toolbarBuilder = _defaultToolbarBuilder,
  })  : assert(children.length > 0),
        super(key: key);

  /// {@macro flutter.material.TextTextSelectionToolbar.anchorAbove}
  final Offset anchorAbove;

  /// {@macro flutter.material.TextTextSelectionToolbar.anchorBelow}
  final Offset anchorBelow;

  /// {@macro flutter.material.TextTextSelectionToolbar.children}
  ///
  /// See also:
  ///   * [TextSelectionToolbarButton], which builds a default
  ///     -style text selection toolbar text button.
  final List<Widget> children;

  /// {@macro flutter.material.TextTextSelectionToolbar.toolbarBuilder}
  ///
  /// The given anchor and isAbove can be used to position an arrow, as in the
  /// default  toolbar.
  final ToolbarBuilder toolbarBuilder;

  // Builds a toolbar just like the default iOS toolbar, with the right color
  // background and a rounded cutout with an arrow.
  static Widget _defaultToolbarBuilder(
    BuildContext context,
    Offset anchor,
    bool isAbove,
    Widget child,
  ) {
    final theme = ThemeProvider.of(context);

    return _TextSelectionToolbarShape(
      anchor: anchor,
      isAbove: isAbove,
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.selectionToolbarBackgroundColor),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final mediaQuery = MediaQuery.of(context);
    final paddingAbove = mediaQuery.padding.top + _kToolbarScreenPadding;
    final toolbarHeightNeeded =
        paddingAbove + _kToolbarContentDistance + _kToolbarHeight;

    final fitsAbove = anchorAbove.dy >= toolbarHeightNeeded;

    const contentPaddingAdjustment = Offset(0.0, _kToolbarContentDistance);
    final localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _kToolbarScreenPadding,
        paddingAbove,
        _kToolbarScreenPadding,
        _kToolbarScreenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove: anchorAbove - localAdjustment - contentPaddingAdjustment,
          anchorBelow: anchorBelow - localAdjustment + contentPaddingAdjustment,
        ),
        child: _TextSelectionToolbarContent(
          anchor: fitsAbove ? anchorAbove : anchorBelow,
          isAbove: fitsAbove,
          toolbarBuilder: toolbarBuilder,
          children: children,
        ),
      ),
    );
  }
}

// Clips the child so that it has the shape of the default iOS text selection
// toolbar, with rounded corners and an arrow pointing at the anchor.
//
// The anchor should be in global coordinates.
class _TextSelectionToolbarShape extends SingleChildRenderObjectWidget {
  const _TextSelectionToolbarShape({
    Key? key,
    required Offset anchor,
    required bool isAbove,
    Widget? child,
  })  : _anchor = anchor,
        _isAbove = isAbove,
        super(key: key, child: child);

  final Offset _anchor;

  // Whether the arrow should point down and be attached to the bottom
  // of the toolbar, or point up and be attached to the top of the toolbar.
  final bool _isAbove;

  @override
  _RenderTextSelectionToolbarShape createRenderObject(BuildContext context) =>
      _RenderTextSelectionToolbarShape(
        _anchor,
        _isAbove,
        null,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTextSelectionToolbarShape renderObject,
  ) {
    renderObject
      ..anchor = _anchor
      ..isAbove = _isAbove;
  }
}

// Clips the child into the shape of the default iOS text selection toolbar.
//
// The shape is a rounded rectangle with a protruding arrow pointing at the
// given anchor in the direction indicated by isAbove.
//
// In order to allow the child to render itself independent of isAbove, its
// height is clipped on both the top and the bottom, leaving the arrow remaining
// on the necessary side.
class _RenderTextSelectionToolbarShape extends RenderShiftedBox {
  _RenderTextSelectionToolbarShape(
    this._anchor,
    this._isAbove,
    RenderBox? child,
  ) : super(child);

  @override
  bool get isRepaintBoundary => true;

  Offset _anchor;
  set anchor(Offset value) {
    if (value == _anchor) {
      return;
    }
    _anchor = value;
    markNeedsLayout();
  }

  bool _isAbove;
  set isAbove(bool value) {
    if (_isAbove == value) {
      return;
    }
    _isAbove = value;
    markNeedsLayout();
  }

  // The child is tall enough to have the arrow clipped out of it on both sides
  // top and bottom. Since _kToolbarHeight includes the height of one arrow, the
  // total height that the child is given is that plus one more arrow height.
  // The extra height on the opposite side of the arrow will be clipped out. By
  // using this approach, the buttons don't need any special padding that
  // depends on isAbove.
  final BoxConstraints _heightConstraint = BoxConstraints.tightFor(
    height: _kToolbarHeight + _kToolbarArrowSize.height,
  );

  @override
  void performLayout() {
    if (child == null) {
      return;
    }

    final enforcedConstraint = constraints.loosen();

    child!.layout(
      _heightConstraint.enforce(enforcedConstraint),
      parentUsesSize: true,
    );

    // The height of one arrow will be clipped off of the child, so adjust the
    // size and position to remove that piece from the layout.
    final childParentData = child!.parentData! as BoxParentData;

    childParentData.offset = Offset(
      0.0,
      _isAbove ? -_kToolbarArrowSize.height : 0.0,
    );

    size = Size(
      child!.size.width,
      child!.size.height - _kToolbarArrowSize.height,
    );
  }

  // The path is described in the toolbar's coordinate system.
  Path _clipPath() {
    final childParentData = child!.parentData! as BoxParentData;
    final rrect = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset(0.0, _kToolbarArrowSize.height) &
              Size(
                child!.size.width,
                child!.size.height - _kToolbarArrowSize.height * 2,
              ),
          _kToolbarBorderRadius,
        ),
      );

    final localAnchor = globalToLocal(_anchor);
    final centerX = childParentData.offset.dx + child!.size.width / 2;
    final arrowXOffsetFromCenter = localAnchor.dx - centerX;
    final arrowTipX = child!.size.width / 2 + arrowXOffsetFromCenter;

    final arrowBaseY = _isAbove
        ? child!.size.height - _kToolbarArrowSize.height
        : _kToolbarArrowSize.height;

    final arrowTipY = _isAbove ? child!.size.height : 0.0;
    final arrow = Path()
      ..moveTo(arrowTipX, arrowTipY)
      ..lineTo(arrowTipX - _kToolbarArrowSize.width / 2, arrowBaseY)
      ..lineTo(arrowTipX + _kToolbarArrowSize.width / 2, arrowBaseY)
      ..close();

    return Path.combine(PathOperation.union, rrect, arrow);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }

    final childParentData = child!.parentData! as BoxParentData;

    _clipPathLayer.layer = context.pushClipPath(
      needsCompositing,
      offset + childParentData.offset,
      Offset.zero & child!.size,
      _clipPath(),
      (PaintingContext innerContext, Offset innerOffset) =>
          innerContext.paintChild(child!, innerOffset),
      oldLayer: _clipPathLayer.layer,
    );
  }

  final _clipPathLayer = LayerHandle<ClipPathLayer>();

  Paint? _debugPaint;

  @override
  void dispose() {
    _clipPathLayer.layer = null;
    super.dispose();
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      if (child == null) {
        return true;
      }

      _debugPaint ??= Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(10.0, 10.0),
          const <Color>[
            Color(0x00000000),
            Color(0xFFFF00FF),
            Color(0xFFFF00FF),
            Color(0x00000000)
          ],
          const <double>[0.25, 0.25, 0.75, 0.75],
          TileMode.repeated,
        )
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final childParentData = child!.parentData! as BoxParentData;

      context.canvas.drawPath(
        _clipPath().shift(offset + childParentData.offset),
        _debugPaint!,
      );

      return true;
    }());
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Positions outside of the clipped area of the child are not counted as
    // hits.
    final childParentData = child!.parentData! as BoxParentData;
    final hitBox = Rect.fromLTWH(
      childParentData.offset.dx,
      childParentData.offset.dy + _kToolbarArrowSize.height,
      child!.size.width,
      child!.size.height - _kToolbarArrowSize.height * 2,
    );

    if (!hitBox.contains(position)) {
      return false;
    }

    return super.hitTestChildren(result, position: position);
  }
}

// A toolbar containing the given children. If they overflow the width
// available, then the menu will be paginated with the overflowing children
// displayed on subsequent pages.
//
// The anchor should be in global coordinates.
class _TextSelectionToolbarContent extends StatefulWidget {
  const _TextSelectionToolbarContent({
    Key? key,
    required this.anchor,
    required this.isAbove,
    required this.toolbarBuilder,
    required this.children,
  })  : assert(children.length > 0),
        super(key: key);

  final Offset anchor;
  final List<Widget> children;
  final bool isAbove;
  final ToolbarBuilder toolbarBuilder;

  @override
  _TextSelectionToolbarContentState createState() =>
      _TextSelectionToolbarContentState();
}

class _TextSelectionToolbarContentState
    extends State<_TextSelectionToolbarContent> {
  @override
  Widget build(BuildContext context) {
    return widget.toolbarBuilder(
      context,
      widget.anchor,
      widget.isAbove,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.children,
      ),
      // TODO: support more than 4 actions
      //
      // child: _TextSelectionToolbarItems(
      //   page: _page,
      //   backButton: TextSelectionToolbarButton(
      //     onPressed: _handlePreviousPage,
      //     text: '◀',
      //   ),
      //   nextButton: TextSelectionToolbarButton(
      //     onPressed: _handleNextPage,
      //     text: '▶',
      //   ),
      //   nextButtonDisabled: const TextSelectionToolbarButton(text: '▶'),
      //   children: widget.children,
      // ),
    );
  }
}
