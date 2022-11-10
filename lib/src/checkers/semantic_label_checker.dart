import 'dart:ui' as ui;
import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'checker_base.dart';

class SemanticLabelChecker extends CheckerBase {
  @override
  List<AccessibilityIssue> getIssues(
    SemanticsNode root,
    Map<SemanticsNode, RenderObject> nodesMap,
  ) {
    final result = <AccessibilityIssue>[];
    final binding = WidgetsBinding.instance;

    void traverse(SemanticsNode node) {
      node.visitChildren((SemanticsNode child) {
        traverse(child);
        return true;
      });

      if (node.isMergedIntoParent ||
          node.isInvisible ||
          node.hasFlag(ui.SemanticsFlag.isHidden)) {
        return;
      }
      final data = node.getSemanticsData();

      // Skip node if it has no actions, or is marked as hidden.
      if (!data.hasAction(ui.SemanticsAction.longPress) &&
          !data.hasAction(ui.SemanticsAction.tap)) {
        return;
      }

      final element = getCreatorElement(nodesMap, node);

      if (shouldIgnore(element)) {
        return;
      }

      final hasLabel =
          data.label.trim().isNotEmpty || data.tooltip.trim().isNotEmpty;

      if (!hasLabel) {
        final paintBounds = getPaintBounds(node);
        result.add(
          AccessibilityIssue(
            message: 'Tap area is missing semantic label',
            node: node,
            rect: Rect.fromLTWH(
              paintBounds.left / binding.window.devicePixelRatio,
              paintBounds.top / binding.window.devicePixelRatio,
              paintBounds.width / binding.window.devicePixelRatio,
              paintBounds.height / binding.window.devicePixelRatio,
            ),
            element: element,
          ),
        );
      }
    }

    traverse(root);
    return result;
  }
}
