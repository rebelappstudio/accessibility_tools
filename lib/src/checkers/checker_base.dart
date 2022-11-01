import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

abstract class CheckerBase {
  List<AccessibilityIssue> getIssues(
    SemanticsNode root,
    Map<SemanticsNode, RenderObject> nodesMap,
  );

  @protected
  Element? getCreatorElement(
    Map<SemanticsNode, RenderObject> nodesMap,
    SemanticsNode node,
  ) {
    final creator = nodesMap[node]?.debugCreator;
    if (creator is DebugCreator) {
      return creator.element;
    }

    return null;
  }

  @protected
  Rect getPaintBounds(SemanticsNode node) {
    Rect paintBounds = node.rect;
    SemanticsNode? current = node;
    while (current != null) {
      if (current.transform != null) {
        paintBounds =
            MatrixUtils.transformRect(current.transform!, paintBounds);
      }
      current = current.parent;
    }

    return paintBounds;
  }

  void traverse(SemanticsNode node) {}

  bool shouldIgnore(Element? element) {
    // Stupid hack to not highlight the inspector button as an accessibility issue
    if (element != null) {
      final inspectorButtonChain = [
        'FloatingActionButton',
        'Positioned',
        'Stack',
        'WidgetInspector',
      ];

      final chain = element
          .debugGetDiagnosticChain()
          .map((e) => e.toStringShort())
          .skip(1)
          .take(inspectorButtonChain.length)
          .toList();

      return listEquals(chain, inspectorButtonChain);
    }

    return false;
  }
}
