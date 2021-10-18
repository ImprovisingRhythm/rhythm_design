import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const kTabScrollDuration = Duration(milliseconds: 300);

class TabController extends ChangeNotifier {
  TabController({
    int initialIndex = 0,
    required this.length,
    required TickerProvider vsync,
  })  : assert(length >= 0),
        assert(initialIndex >= 0 && (length == 0 || initialIndex < length)),
        _index = initialIndex,
        _previousIndex = initialIndex,
        _animationController = AnimationController.unbounded(
          value: initialIndex.toDouble(),
          vsync: vsync,
        );

  Animation<double>? get animation => _animationController?.view;
  AnimationController? _animationController;

  final int length;

  void _changeIndex(int value, {Duration? duration, Curve? curve}) {
    assert(value >= 0 && (value < length || length == 0));
    assert(duration != null || curve == null);
    assert(_indexIsChangingCount >= 0);

    if (value == _index || length < 2) {
      return;
    }

    _previousIndex = index;
    _index = value;

    if (duration != null) {
      _indexIsChangingCount += 1;
      notifyListeners(); // Because the value of indexIsChanging may have changed.

      _animationController!
          .animateTo(_index.toDouble(), duration: duration, curve: curve!)
          .whenCompleteOrCancel(() {
        if (_animationController != null) {
          // don't notify if we've been disposed
          _indexIsChangingCount -= 1;
          notifyListeners();
        }
      });
    } else {
      _indexIsChangingCount += 1;
      _animationController!.value = _index.toDouble();
      _indexIsChangingCount -= 1;
      notifyListeners();
    }
  }

  int get index => _index;
  int _index;
  set index(int value) {
    _changeIndex(value);
  }

  int get previousIndex => _previousIndex;
  int _previousIndex;

  bool get indexIsChanging => _indexIsChangingCount != 0;
  int _indexIsChangingCount = 0;

  void animateTo(
    int value, {
    Duration duration = kTabScrollDuration,
    Curve curve = Curves.ease,
  }) {
    _changeIndex(value, duration: duration, curve: curve);
  }

  double get offset => _animationController!.value - _index.toDouble();
  set offset(double value) {
    assert(value >= -1.0 && value <= 1.0);
    assert(!indexIsChanging);

    if (value == offset) {
      return;
    }

    _animationController!.value = value + _index.toDouble();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
    super.dispose();
  }
}

class TabView extends StatefulWidget {
  const TabView({
    Key? key,
    required this.children,
    required this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final TabController controller;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final DragStartBehavior dragStartBehavior;

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  TabController? _controller;

  late PageController _pageController;
  late List<Widget> _children;
  late List<Widget> _childrenWithKey;

  int? _currentIndex;
  int _warpUnderwayCount = 0;

  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    if (widget.controller == _controller) return;

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }

    _controller = widget.controller;
    _controller!.animation!.addListener(_handleTabControllerAnimationTick);
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _updateTabController();
    _currentIndex = _controller?.index;
    _pageController = PageController(initialPage: _currentIndex ?? 0);
  }

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }

    if (widget.children != oldWidget.children && _warpUnderwayCount == 0) {
      _updateChildren();
    }
  }

  @override
  void dispose() {
    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }

    _controller = null;
    super.dispose();
  }

  void _updateChildren() {
    _children = widget.children;
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  void _handleTabControllerAnimationTick() {
    if (_warpUnderwayCount > 0 || !_controller!.indexIsChanging) {
      return; // This widget is driving the controller's animation.
    }

    if (_controller!.index != _currentIndex) {
      _currentIndex = _controller!.index;
      _warpToCurrentIndex();
    }
  }

  Future<void> _warpToCurrentIndex() async {
    if (!mounted) return;
    if (_pageController.page == _currentIndex!.toDouble()) return;

    final previousIndex = _controller!.previousIndex;

    if ((_currentIndex! - previousIndex).abs() == 1) {
      _warpUnderwayCount += 1;

      await _pageController.animateToPage(
        _currentIndex!,
        duration: kTabScrollDuration,
        curve: Curves.ease,
      );

      _warpUnderwayCount -= 1;
      return;
    }

    assert((_currentIndex! - previousIndex).abs() > 1);

    final initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;

    final originalChildren = _childrenWithKey;

    setState(() {
      _warpUnderwayCount += 1;
      _childrenWithKey = List<Widget>.from(_childrenWithKey, growable: false);

      final temp = _childrenWithKey[initialPage];

      _childrenWithKey[initialPage] = _childrenWithKey[previousIndex];
      _childrenWithKey[previousIndex] = temp;
    });

    _pageController.jumpToPage(initialPage);

    await _pageController.animateToPage(
      _currentIndex!,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );

    if (!mounted) return;

    setState(() {
      _warpUnderwayCount -= 1;

      if (widget.children != _children) {
        _updateChildren();
      } else {
        _childrenWithKey = originalChildren;
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_warpUnderwayCount > 0) return false;
    if (notification.depth != 0) return false;

    _warpUnderwayCount += 1;

    if (notification is ScrollUpdateNotification &&
        !_controller!.indexIsChanging) {
      if ((_pageController.page! - _controller!.index).abs() > 1.0) {
        _controller!.index = _pageController.page!.floor();
        _currentIndex = _controller!.index;
      }

      _controller!.offset =
          (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
    } else if (notification is ScrollEndNotification) {
      _controller!.index = _pageController.page!.round();
      _currentIndex = _controller!.index;

      if (!_controller!.indexIsChanging) {
        _controller!.offset =
            (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
      }
    }

    _warpUnderwayCount -= 1;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.children.length) {
        throw FlutterError(
          "Controller's length property (${_controller!.length}) does not match the "
          "number of tabs (${widget.children.length}) present in TabBar's tabs property.",
        );
      }
      return true;
    }());

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: PageView(
        dragStartBehavior: widget.dragStartBehavior,
        controller: _pageController,
        physics: widget.physics == null
            ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
            : const PageScrollPhysics().applyTo(widget.physics),
        children: _childrenWithKey,
      ),
    );
  }
}
