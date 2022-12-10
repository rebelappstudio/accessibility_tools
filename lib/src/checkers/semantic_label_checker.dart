import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

class SemanticLabelChecker extends SemanticsNodeChecker {
  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (node.isMergedIntoParent ||
        node.isInvisible ||
        node.hasFlag(ui.SemanticsFlag.isHidden)) {
      return null;
    }

    final data = node.getSemanticsData();
    if (data.isTappable) {
      final hasLabel =
          data.label.trim().isNotEmpty || data.tooltip.trim().isNotEmpty;

      if (!hasLabel) {
        return AccessibilityIssue(
          message: 'Tap area is a missing semantic label',
          renderObject: renderObject,
        );
      }
    }

    return null;
  }
}
