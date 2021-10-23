import 'dart:async';
import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../app/theme_provider.dart';
import 'activity_indicator.dart';
import 'empty_box.dart';
import 'listenable_builder.dart';
import 'null_widget.dart';
import 'sliver_refresh_control.dart';

const _kAutoScrollDuration = Duration(milliseconds: 250);

typedef ListViewItemBuilder = Widget Function(BuildContext context, int index);

class ExtendedListView extends StatefulWidget {
  const ExtendedListView({
    Key? key,
    this.controller,
    this.keyboardAvoiding = false,
    this.reverse = false,
    this.primary,
    this.physics,
    this.cacheExtent,
    this.startItems,
    this.endItems,
    this.itemCount,
    this.itemBuilder,
    this.startSpacing = 0,
    this.endSpacing = 0,
    this.horizontalSpacing = 0,
    this.forceRefreshTime = const Duration(milliseconds: 800),
    this.onRefresh,
    this.onLoad,
  })  : assert(!keyboardAvoiding || controller != null),
        super(key: key);

  final ScrollController? controller;
  final bool keyboardAvoiding;
  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final List<Widget>? startItems;
  final List<Widget>? endItems;
  final int? itemCount;
  final ListViewItemBuilder? itemBuilder;
  final double startSpacing;
  final double endSpacing;
  final double horizontalSpacing;
  final Duration forceRefreshTime;
  final Future<void> Function()? onRefresh;
  final Future<bool> Function()? onLoad;

  @override
  ExtendedListViewState createState() => ExtendedListViewState();
}

class ExtendedListViewState extends State<ExtendedListView> {
  final _scrollViewKey = GlobalKey();
  final _listModel = ListModel();

  void reset() {
    _listModel.reset();
  }

  Future<void> _onScroll(ScrollNotification notification) async {
    if (_listModel.loading || !_listModel.hasMore) {
      return;
    }

    final metrics = notification.metrics;

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        _listModel.unlock();
      }
    }

    if (_listModel.locked) {
      return;
    }

    if (metrics.outOfRange && metrics.pixels >= metrics.maxScrollExtent) {
      _listModel.lock();
      _listModel.startLoading();

      try {
        _listModel.hasMore = await widget.onLoad!();
      } finally {
        _listModel.stopLoading();
      }
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait<void>([
      widget.onRefresh!(),
      Future.delayed(widget.forceRefreshTime),
    ]);
  }

  void _scrollToFocusedObject() {
    final renderObject = context.findRenderObject();

    if (renderObject != null) {
      final focused = _findFocusedObject(renderObject);

      if (focused != null) {
        _scrollToObject(focused);
      }
    }
  }

  RenderObject? _findFocusedObject(RenderObject root) {
    final q = Queue<RenderObject>();
    q.add(root);

    while (q.isNotEmpty) {
      final node = q.removeFirst();

      if (node is RenderEditable && node.hasFocus) {
        return node;
      }

      node.visitChildren((child) {
        q.add(child);
      });
    }

    return null;
  }

  void _scrollToObject(RenderObject object) {
    final controller = widget.controller;

    if (controller != null) {
      final theme = ThemeProvider.of(context);
      final mediaQuery = MediaQuery.of(context);
      final keyboardHeight = mediaQuery.viewInsets.bottom;
      final screenHeight = mediaQuery.size.height;
      final box = object as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;
      final offset = position.dy + size.height + theme.spacing * 2;
      final delta = offset - (screenHeight - keyboardHeight);

      if (delta > 0) {
        controller.animateTo(
          controller.position.pixels + delta,
          duration: _kAutoScrollDuration,
          curve: Curves.ease,
        );
      }
    }
  }

  Widget _horizontalSpacingWrap(Widget sliver) {
    if (widget.horizontalSpacing > 0) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalSpacing),
        sliver: sliver,
      );
    }

    return sliver;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final keyboardVisible = mediaQuery.viewInsets.bottom > 50.0;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (widget.onLoad != null) {
          _onScroll(notification);
        }
        return true;
      },
      child: CustomScrollView(
        key: _scrollViewKey,
        scrollDirection: Axis.vertical,
        controller: widget.controller,
        cacheExtent: widget.cacheExtent,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        slivers: [
          if (widget.startSpacing > 0)
            SliverPersistentHeader(
              delegate: _PaddingTopSliverDelegate(extent: widget.startSpacing),
            ),
          if (!widget.reverse && widget.onRefresh != null)
            SliverRefreshControl(onRefresh: _onRefresh),
          if (widget.startItems != null)
            _horizontalSpacingWrap(SliverList(
              delegate: SliverChildListDelegate(widget.startItems!),
            )),
          if (widget.itemBuilder != null)
            _horizontalSpacingWrap(SliverList(
              delegate: SliverChildBuilderDelegate(
                widget.itemBuilder!,
                childCount: widget.itemCount,
              ),
            )),
          if (widget.endItems != null)
            _horizontalSpacingWrap(SliverList(
              delegate: SliverChildListDelegate(widget.endItems!),
            )),
          if (widget.onLoad != null)
            SliverToBoxAdapter(
              child: ListenableBuilder<ListModel>(
                value: _listModel,
                builder: (context, list, child) {
                  return AnimatedSize(
                    duration: list.loading
                        ? const Duration(microseconds: 1)
                        : _kAutoScrollDuration,
                    curve: Curves.decelerate,
                    clipBehavior: Clip.none,
                    child: list.loading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: ActivityIndicator(),
                          )
                        : const NullWidget(),
                  );
                },
              ),
            ),
          if (widget.endSpacing > 0) SliverEmptyBox(extent: widget.endSpacing),
          if (widget.keyboardAvoiding)
            SliverToBoxAdapter(
              child: AnimatedContainer(
                onEnd: () {
                  if (keyboardVisible) {
                    _scrollToFocusedObject();
                  }
                },
                curve: Curves.ease,
                height: keyboardVisible ? keyboardHeight : 0.0,
                duration: !keyboardVisible
                    ? _kAutoScrollDuration
                    : const Duration(microseconds: 1),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaddingTopSliverDelegate extends SliverPersistentHeaderDelegate {
  const _PaddingTopSliverDelegate({required this.extent});

  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const NullWidget();
  }

  @override
  bool shouldRebuild(_PaddingTopSliverDelegate oldDelegate) {
    return false;
  }
}

class ListModel extends ChangeNotifier {
  bool hasMore = true;
  bool locked = false;
  bool loading = false;

  void startLoading() {
    loading = true;
    notifyListeners();
  }

  void stopLoading() {
    loading = false;
    notifyListeners();
  }

  void lock() {
    locked = true;
  }

  void unlock() {
    locked = false;
  }

  void reset() {
    hasMore = true;
    locked = false;
    loading = false;
    notifyListeners();
  }
}
