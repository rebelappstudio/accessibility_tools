import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Modified from package:flutter_test/lib/src/accessibility.dart
class MinimumTapAreaChecker extends SemanticsNodeChecker {
  final double minTapArea;

  MinimumTapAreaChecker({required this.minTapArea});

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
      // Item size doesn't match tap area height - it's probably partially off screen
      return null;
    }

    const delta = 0.001;
    if (size.width < minTapArea - delta || size.height < minTapArea - delta) {
      return AccessibilityIssue(
        message:
            'Tap area of ${size.width}x${size.height} is too small; should be at least ${minTapArea}x$minTapArea',
        renderObject: renderObject,
      );
    }

    return null;
  }
}
