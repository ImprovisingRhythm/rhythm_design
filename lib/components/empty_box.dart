import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RenderEmptyBox extends RenderBox {
  RenderEmptyBox({
    this.width = 0,
    this.height = 0,
  });

  double width;
  double height;

  @override
  void performLayout() {
    size = BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: height,
      maxHeight: height,
    ).enforce(constraints).constrain(Size.zero);
  }
}

class EmptyBox extends SingleChildRenderObjectWidget {
  const EmptyBox({
    Key? key,
    this.width = 0,
    this.height = 0,
  }) : super(key: key);

  final double width;
  final double height;

  @override
  RenderEmptyBox createRenderObject(BuildContext context) {
    return RenderEmptyBox(
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderEmptyBox renderObject,
  ) {
    renderObject
      ..width = width
      ..height = height;
  }

  @override
  String toStringShort() {
    return objectRuntimeType(this, 'EmptyBox');
  }
}

class RenderSliverEmptyBox extends RenderSliver {
  RenderSliverEmptyBox({this.extent = 0});

  double extent;

  @override
  void performLayout() {
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: min(extent, constraints.remainingPaintExtent),
      maxPaintExtent: extent,
    );
  }
}

class SliverEmptyBox extends SingleChildRenderObjectWidget {
  const SliverEmptyBox({
    Key? key,
    this.extent = 0,
  }) : super(key: key);

  final double extent;

  @override
  RenderSliverEmptyBox createRenderObject(BuildContext context) {
    return RenderSliverEmptyBox(extent: extent);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverEmptyBox renderObject,
  ) {
    renderObject.extent = extent;
  }

  @override
  String toStringShort() {
    return objectRuntimeType(this, 'SliverEmptyBox');
  }
}
