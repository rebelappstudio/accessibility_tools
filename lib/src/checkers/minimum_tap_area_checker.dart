import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

/// Modified from package:flutter_test/lib/src/accessibility.dart
class MinimumTapAreaChecker extends SemanticsNodeChecker {
  MinimumTapAreaChecker({required this.minTapArea});
  final double minTapArea;

  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (node.isMergedIntoParent || !node.getSemanticsData().isTappable) {
      return null;
    }

    final paintBounds = getPaintBounds(node);
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final size = paintBounds.size / devicePixelRatio;
    final element = renderObject.getCreatorElement();

    if (element?.size != null && element?.size != size) {
      // Item size doesn't match tap area height - it's probably partially off
      // screen
      return null;
    }

    const delta = 0.001;
    if (size.width < minTapArea - delta || size.height < minTapArea - delta) {
      return AccessibilityIssue(
        message: '''
Tap area of ${_format(size.width)}x${_format(size.height)} is too small:
should be at least ${_format(minTapArea)}x${_format(minTapArea)}''',
        renderObject: renderObject,
      );
    }

    return null;
  }

  String _format(double val) {
    return (val % 1 == 0 ? val.toInt() : val).toString();
  }
}
