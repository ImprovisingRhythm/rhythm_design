import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class NullWidget extends SingleChildRenderObjectWidget {
  const NullWidget({Key? key}) : super(key: key);

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(additionalConstraints: const BoxConstraints());
  }

  @override
  String toStringShort() {
    return objectRuntimeType(this, 'NullWidget');
  }
}

class NullSliverWidget extends SingleChildRenderObjectWidget {
  const NullSliverWidget({Key? key}) : super(key: key);

  @override
  RenderSliverToBoxAdapter createRenderObject(BuildContext context) {
    return RenderSliverToBoxAdapter();
  }

  @override
  String toStringShort() {
    return objectRuntimeType(this, 'NullSliverWidget');
  }
}
