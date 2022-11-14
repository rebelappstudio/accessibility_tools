import 'dart:ui' as ui;
import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

abstract class CheckerBase extends ChangeNotifier {
  List<AccessibilityIssue> _issues = [];
  List<AccessibilityIssue> get issues => _issues;
  set issues(List<AccessibilityIssue> issues) {
    _issues = issues;
    notifyListeners();
  }

  void didUpdateSemantics(List<RenderObject> semanticRenderObjects);

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
  Rect? getRect(RenderObject renderObject, SemanticsNode node) {
    final translation = renderObject.getTransformTo(null).getTranslation();
    final offset = Offset(translation.x, translation.y);
    return renderObject.paintBounds.shift(offset);
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

abstract class SemanticsNodeChecker extends CheckerBase {
  @override
  void didUpdateSemantics(List<RenderObject> semanticRenderObjects) {
    issues = semanticRenderObjects
        .map((node) => checkNode(node.debugSemantics!, node))
        .whereNotNull()
        .toList();
  }

  AccessibilityIssue? checkNode(
    SemanticsNode node,
    RenderObject renderObject,
  );
}

abstract class WidgetCheckerBase extends CheckerBase {
  Widget build(BuildContext context, Widget child);
}

extension RenderObjectExtension on RenderObject {
  @protected
  Rect getGlobalRect() {
    final translation = getTransformTo(null).getTranslation();
    final offset = Offset(translation.x, translation.y);
    return paintBounds.shift(offset);
  }

  Element? getCreatorElement() {
    final creator = debugCreator;
    if (creator is DebugCreator) {
      return creator.element;
    }

    return null;
  }
}

extension SemanticsDataExtension on SemanticsData {
  bool get isTappable {
    return hasAction(ui.SemanticsAction.longPress) ||
        hasAction(ui.SemanticsAction.tap);
  }
}
