import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import '../utils/platform_features.dart';

// Eyeballed values comparing with a native picker to produce the right
// curvatures and densities.
const _kDefaultDiameterRatio = 1.07;
const _kDefaultPerspective = 0.003;
const _kSqueeze = 1.45;

// Opacity fraction value that dims the wheel above and below the "magnifier"
// lens.
const _kOverAndUnderCenterOpacity = 0.447;
const _kDefaultItemExtent = 50.0;

class PickerBottomSheet extends StatelessWidget {
  const PickerBottomSheet({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Picker child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class PickerItem extends StatelessWidget {
  const PickerItem({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    return Center(
      child: Text(
        text,
        style: theme.pickerTextStyle,
      ),
    );
  }
}

class Picker extends StatefulWidget {
  /// Creates a picker from a concrete list of children.
  ///
  /// The [diameterRatio] and [itemExtent] arguments must not be null. The
  /// [itemExtent] must be greater than zero.
  ///
  /// The [scrollController] argument can be used to specify a custom
  /// [FixedExtentScrollController] for programmatically reading or changing
  /// the current picker index or for selecting an initial index value.
  ///
  /// The [looping] argument decides whether the child list loops and can be
  /// scrolled infinitely.  If set to true, scrolling past the end of the list
  /// will loop the list back to the beginning.  If set to false, the list will
  /// stop scrolling when you reach the end or the beginning.
  Picker({
    Key? key,
    this.diameterRatio = _kDefaultDiameterRatio,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.scrollController,
    this.squeeze = _kSqueeze,
    this.itemExtent = _kDefaultItemExtent,
    required this.onSelectedItemChanged,
    required List<Widget> children,
    this.selectionOverlay = const PickerDefaultSelectionOverlay(),
    bool looping = false,
  })  : assert(
          diameterRatio > 0.0,
          RenderListWheelViewport.diameterRatioZeroMessage,
        ),
        assert(magnification > 0),
        assert(itemExtent > 0),
        assert(squeeze > 0),
        childDelegate = looping
            ? ListWheelChildLoopingListDelegate(children: children)
            : ListWheelChildListDelegate(children: children),
        super(key: key);

  /// Creates a picker from an [IndexedWidgetBuilder] callback where the builder
  /// is dynamically invoked during layout.
  ///
  /// A child is lazily created when it starts becoming visible in the viewport.
  /// All of the children provided by the builder are cached and reused, so
  /// normally the builder is only called once for each index (except when
  /// rebuilding - the cache is cleared).
  ///
  /// The [itemBuilder] argument must not be null. The [childCount] argument
  /// reflects the number of children that will be provided by the [itemBuilder].
  /// {@macro flutter.widgets.ListWheelChildBuilderDelegate.childCount}
  ///
  /// The [itemExtent] argument must be non-null and positive.
  Picker.builder({
    Key? key,
    this.diameterRatio = _kDefaultDiameterRatio,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.scrollController,
    this.squeeze = _kSqueeze,
    this.itemExtent = _kDefaultItemExtent,
    required this.onSelectedItemChanged,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? childCount,
    this.selectionOverlay = const PickerDefaultSelectionOverlay(),
  })  : assert(
          diameterRatio > 0.0,
          RenderListWheelViewport.diameterRatioZeroMessage,
        ),
        assert(magnification > 0),
        assert(itemExtent > 0),
        assert(squeeze > 0),
        childDelegate = ListWheelChildBuilderDelegate(
            builder: itemBuilder, childCount: childCount),
        super(key: key);

  /// Relative ratio between this picker's height and the simulated cylinder's diameter.
  ///
  /// Smaller values creates more pronounced curvatures in the scrollable wheel.
  ///
  /// For more details, see [ListWheelScrollView.diameterRatio].
  ///
  /// Must not be null and defaults to `1.1` to visually mimic iOS.
  final double diameterRatio;

  /// {@macro flutter.rendering.RenderListWheelViewport.offAxisFraction}
  final double offAxisFraction;

  /// {@macro flutter.rendering.RenderListWheelViewport.useMagnifier}
  final bool useMagnifier;

  /// {@macro flutter.rendering.RenderListWheelViewport.magnification}
  final double magnification;

  /// A [FixedExtentScrollController] to read and control the current item, and
  /// to set the initial item.
  ///
  /// If null, an implicit one will be created internally.
  final FixedExtentScrollController? scrollController;

  /// The uniform height of all children.
  ///
  /// All children will be given the [BoxConstraints] to match this exact
  /// height. Must not be null and must be positive.
  final double itemExtent;

  /// {@macro flutter.rendering.RenderListWheelViewport.squeeze}
  ///
  /// Defaults to `1.45` to visually mimic iOS.
  final double squeeze;

  /// An option callback when the currently centered item changes.
  ///
  /// Value changes when the item closest to the center changes.
  ///
  /// This can be called during scrolls and during ballistic flings. To get the
  /// value only when the scrolling settles, use a [NotificationListener],
  /// listen for [ScrollEndNotification] and read its [FixedExtentMetrics].
  final ValueChanged<int>? onSelectedItemChanged;

  /// A delegate that lazily instantiates children.
  final ListWheelChildDelegate childDelegate;

  /// A widget overlaid on the picker to highlight the currently selected entry.
  ///
  /// The [selectionOverlay] widget drawn above the [Picker]'s picker
  /// wheel.
  /// It is vertically centered in the picker and is constrained to have the
  /// same height as the center row.
  ///
  /// If unspecified, it defaults to a [PickerDefaultSelectionOverlay]
  /// which is a gray rounded rectangle overlay in iOS 14 style.
  /// This property can be set to null to remove the overlay.
  final Widget? selectionOverlay;

  @override
  State<StatefulWidget> createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  int? _lastHapticIndex;
  FixedExtentScrollController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _controller = FixedExtentScrollController();
    }
  }

  @override
  void didUpdateWidget(Picker oldWidget) {
    if (widget.scrollController != null && oldWidget.scrollController == null) {
      _controller = null;
    } else if (widget.scrollController == null &&
        oldWidget.scrollController != null) {
      assert(_controller == null);
      _controller = FixedExtentScrollController();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleSelectedItemChanged(int index) {
    if (hasSuitableHapticHardware && index != _lastHapticIndex) {
      _lastHapticIndex = index;
      HapticFeedback.selectionClick();
    }

    widget.onSelectedItemChanged?.call(index);
  }

  /// Draws the selectionOverlay.
  Widget _buildSelectionOverlay(Widget selectionOverlay) {
    final double height = widget.itemExtent * widget.magnification;

    return IgnorePointer(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(
            height: height,
          ),
          child: selectionOverlay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: _PickerSemantics(
            scrollController: widget.scrollController ?? _controller!,
            child: ListWheelScrollView.useDelegate(
              controller: widget.scrollController ?? _controller,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: widget.diameterRatio,
              perspective: _kDefaultPerspective,
              offAxisFraction: widget.offAxisFraction,
              useMagnifier: widget.useMagnifier,
              magnification: widget.magnification,
              overAndUnderCenterOpacity: _kOverAndUnderCenterOpacity,
              itemExtent: widget.itemExtent,
              squeeze: widget.squeeze,
              onSelectedItemChanged: _handleSelectedItemChanged,
              childDelegate: widget.childDelegate,
            ),
          ),
        ),
        if (widget.selectionOverlay != null)
          _buildSelectionOverlay(widget.selectionOverlay!),
      ],
    );
  }
}

class PickerDefaultSelectionOverlay extends StatelessWidget {
  const PickerDefaultSelectionOverlay({
    Key? key,
    this.capLeftEdge = true,
    this.capRightEdge = true,
  }) : super(key: key);

  /// Whether to use the default use rounded corners and margin on the left side.
  final bool capLeftEdge;

  /// Whether to use the default use rounded corners and margin on the right side.
  final bool capRightEdge;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final radius = theme.radius;

    return Container(
      margin: EdgeInsets.only(
        left: capLeftEdge ? theme.pickerSelectionOverlayHorizontalMargin : 0,
        right: capRightEdge ? theme.pickerSelectionOverlayHorizontalMargin : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          left: capLeftEdge ? radius : Radius.zero,
          right: capRightEdge ? radius : Radius.zero,
        ),
        color: theme.focusColor,
      ),
    );
  }
}

// Turns the scroll semantics of the ListView into a single adjustable semantics
// node. This is done by removing all of the child semantics of the scroll
// wheel and using the scroll indexes to look up the current, previous, and
// next semantic label. This label is then turned into the value of a new
// adjustable semantic node, with adjustment callbacks wired to move the
// scroll controller.
class _PickerSemantics extends SingleChildRenderObjectWidget {
  const _PickerSemantics({
    Key? key,
    Widget? child,
    required this.scrollController,
  }) : super(key: key, child: child);

  final FixedExtentScrollController scrollController;

  @override
  RenderObject createRenderObject(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    return _RenderPickerSemantics(scrollController, Directionality.of(context));
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderPickerSemantics renderObject,
  ) {
    assert(debugCheckHasDirectionality(context));

    renderObject
      ..textDirection = Directionality.of(context)
      ..controller = scrollController;
  }
}

class _RenderPickerSemantics extends RenderProxyBox {
  _RenderPickerSemantics(
    FixedExtentScrollController controller,
    this._textDirection,
  ) {
    _updateController(null, controller);
  }

  FixedExtentScrollController get controller => _controller;
  late FixedExtentScrollController _controller;
  set controller(FixedExtentScrollController value) =>
      _updateController(_controller, value);

  // This method exists to allow controller to be non-null. It is only called with a null oldValue from constructor.
  void _updateController(
    FixedExtentScrollController? oldValue,
    FixedExtentScrollController value,
  ) {
    if (value == oldValue) return;
    if (oldValue != null) {
      oldValue.removeListener(_handleScrollUpdate);
    } else {
      _currentIndex = value.initialItem;
    }

    value.addListener(_handleScrollUpdate);
    _controller = value;
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (textDirection == value) return;
    _textDirection = value;
    markNeedsSemanticsUpdate();
  }

  int _currentIndex = 0;

  void _handleIncrease() {
    controller.jumpToItem(_currentIndex + 1);
  }

  void _handleDecrease() {
    if (_currentIndex == 0) return;
    controller.jumpToItem(_currentIndex - 1);
  }

  void _handleScrollUpdate() {
    if (controller.selectedItem == _currentIndex) return;
    _currentIndex = controller.selectedItem;
    markNeedsSemanticsUpdate();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    config.textDirection = textDirection;
  }

  @override
  void assembleSemanticsNode(
    SemanticsNode node,
    SemanticsConfiguration config,
    Iterable<SemanticsNode> children,
  ) {
    if (children.isEmpty) {
      return super.assembleSemanticsNode(node, config, children);
    }

    final scrollable = children.first;
    final indexedChildren = <int, SemanticsNode>{};

    scrollable.visitChildren((SemanticsNode child) {
      assert(child.indexInParent != null);
      indexedChildren[child.indexInParent!] = child;
      return true;
    });

    if (indexedChildren[_currentIndex] == null) {
      return node.updateWith(config: config);
    }

    config.value = indexedChildren[_currentIndex]!.label;

    final previousChild = indexedChildren[_currentIndex - 1];
    final nextChild = indexedChildren[_currentIndex + 1];

    if (nextChild != null) {
      config.increasedValue = nextChild.label;
      config.onIncrease = _handleIncrease;
    }

    if (previousChild != null) {
      config.decreasedValue = previousChild.label;
      config.onDecrease = _handleDecrease;
    }

    node.updateWith(config: config);
  }
}
