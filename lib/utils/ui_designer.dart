import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/empty_box.dart';

Color emphasize(Color color, [int percent = 10]) {
  if (estimateColorBrightness(color) == Brightness.dark) {
    return lighten(color, percent);
  }

  return darken(color, percent);
}

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

Color lighten(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}

Brightness estimateColorBrightness(Color color) {
  final relativeLuminance = color.computeLuminance();
  const kThreshold = 0.15;

  if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
    return Brightness.light;
  }

  return Brightness.dark;
}

Iterable<T> intersperse<T>(T element, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;

  if (iterator.moveNext()) {
    yield iterator.current;

    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }
}

List<Widget> spacingY(double spacing, List<Widget> children) {
  if (children.isEmpty) return children;
  return intersperse(EmptyBox(height: spacing), children).toList();
}

List<Widget> spacingX(double spacing, List<Widget> children) {
  if (children.isEmpty) return children;
  return intersperse(EmptyBox(width: spacing), children).toList();
}

List<Widget> sliverSpacing(double spacing, List<Widget> children) {
  if (children.isEmpty) return children;
  return intersperse(SliverEmptyBox(extent: spacing), children).toList();
}
