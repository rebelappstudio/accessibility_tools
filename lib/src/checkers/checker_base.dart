import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../accessibility_issue.dart';

/// A base class for all accessibility checkers.
///
/// A checker is used to check the accessibility of a widget tree.
///
/// See also:
/// * [SemanticsNodeChecker]
/// * [WidgetCheckerBase]
abstract class CheckerBase extends ChangeNotifier {
  List<AccessibilityIssue> _issues = [];

  /// Issues found by this checker.
  List<AccessibilityIssue> get issues => _issues;

  set issues(List<AccessibilityIssue> issues) {
    _issues = issues;
    notifyListeners();
  }

  /// Notifies the checker that semantics of the widget tree has changed and
  /// it's time to check the accessibility of the widget tree.
  void didUpdateSemantics(List<RenderObject> semanticRenderObjects);

  /// Returns the paint bounds of a semantics [node].
  @protected
  Rect getPaintBounds(SemanticsNode node) {
    Rect paintBounds = node.rect;
    SemanticsNode? current = node;
    while (current != null) {
      if (current.transform != null) {
        paintBounds = MatrixUtils.transformRect(
          current.transform!,
          paintBounds,
        );
      }
      current = current.parent;
    }

    return paintBounds;
  }
}

/// A base class for all semantics node checkers.
///
/// A semantics node checker goes through all semantics nodes in the widget tree
/// and checks for accessibility issues present in the semantics nodes (missing
/// labels, too long labels, tap area sizes, etc.).
///
/// Each checker should check for a single type of accessibility issue.
abstract class SemanticsNodeChecker extends CheckerBase {
  @override
  void didUpdateSemantics(List<RenderObject> semanticRenderObjects) {
    issues = semanticRenderObjects
        .map((node) => checkNode(node.debugSemantics!, node))
        .nonNulls
        .toList();
  }

  /// Checks the accessibility of a semantics [node] and returns an
  /// [AccessibilityIssue] if an issue is found.
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject);
}

/// A base class for all widget checkers.
///
/// Widget checkers can check for accessibility issues when a widget is built.
/// Widget checkers should directly update the issues list on
/// [didUpdateSemantics] call.
abstract class WidgetCheckerBase extends CheckerBase {
  /// Build the [child] widget and check for accessibility issues.
  Widget build(BuildContext context, Widget child);
}

/// Extension on [RenderObject]
extension RenderObjectExtension on RenderObject {
  /// Returns the global rect of the render object.
  Rect getGlobalRect() {
    assert(attached, 'RenderObject must be attached to get global rect');

    final translation = getTransformTo(null).getTranslation();
    final offset = Offset(translation.x, translation.y);
    return paintBounds.shift(offset);
  }
}

/// Extension on [SemanticsData]
extension SemanticsDataExtension on SemanticsData {
  /// Returns true if the semantics data is marked as tappable.
  bool get isTappable {
    return hasAction(ui.SemanticsAction.longPress) ||
        hasAction(ui.SemanticsAction.tap);
  }

  /// Returns true if the semantics data is marked as a form widget.
  bool get isFormWidget {
    return flagsCollection.isTextField ||
        flagsCollection.hasCheckedState ||
        flagsCollection.hasToggledState;
  }

  /// Returns true if the semantics data is marked as an image.
  bool get isImage {
    return flagsCollection.isImage;
  }
}
