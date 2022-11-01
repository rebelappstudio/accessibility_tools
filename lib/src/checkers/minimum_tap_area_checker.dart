import 'dart:ui' as ui;
import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Modified version from package:flutter_test/lib/src/accessibility.dart
class MinimumTapAreaChecker extends CheckerBase {
  final double minTapArea;

  MinimumTapAreaChecker({required this.minTapArea});

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

      if (node.isMergedIntoParent) {
        return;
      }

      final data = node.getSemanticsData();
      // Skip node if it has no actions, or is marked as hidden.
      if ((!data.hasAction(ui.SemanticsAction.longPress) &&
              !data.hasAction(ui.SemanticsAction.tap)) ||
          data.hasFlag(ui.SemanticsFlag.isHidden)) {
        return;
      }
      // Skip links https://www.w3.org/WAI/WCAG21/Understanding/target-size.html
      if (data.hasFlag(ui.SemanticsFlag.isLink)) {
        return;
      }

      final paintBounds = getPaintBounds(node);

      // shrink by device pixel ratio.
      final candidateSize = paintBounds.size / binding.window.devicePixelRatio;
      final element = getCreatorElement(nodesMap, node);

      if (element?.size != null && element?.size != candidateSize) {
        // Item size doesn't match tap area height - it's probably partially off screen
        return;
      }

      const delta = 0.001;
      if (candidateSize.width < minTapArea - delta ||
          candidateSize.height < minTapArea - delta) {
        result.add(
          AccessibilityIssue(
            message:
                'Tap area of ${candidateSize.width}x${candidateSize.height} is too small; should be at least ${minTapArea}x$minTapArea',
            node: node,
            rect: Rect.fromLTWH(
              paintBounds.left / binding.window.devicePixelRatio,
              paintBounds.top / binding.window.devicePixelRatio,
              candidateSize.width,
              candidateSize.height,
            ),
            element: element,
          ),
        );
      }

      return;
    }

    traverse(root);
    return result;
  }
}
