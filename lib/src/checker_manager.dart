import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'accessibility_issue.dart';
import 'checkers/checker_base.dart';

/// Checks for accessibility issues, updating whenever the semantic tree
/// changes.
class CheckerManager extends ChangeNotifier {
  CheckerManager(this.checkers) {
    // Rebuild values (list of [issues]) when dependencies change
    for (final checker in checkers) {
      checker.addListener(notifyListeners);
    }
  }

  final Iterable<CheckerBase> checkers;
  List<AccessibilityIssue> _issues = [];

  List<AccessibilityIssue> get issues {
    final newIssues = checkers.map((e) => e.issues).flattened.toList();
    final issuesHaveChanged = !listEquals(_issues, newIssues);

    if (newIssues.isNotEmpty && issuesHaveChanged) {
      _issues = newIssues;
      _logAccessibilityIssues(_issues);
    }

    return _issues;
  }

  @override
  void dispose() {
    for (final checker in checkers) {
      checker.removeListener(notifyListeners);
    }

    super.dispose();
  }

  /// Called whenever the semantic tree updates.
  void update(CheckerUpdateType updateType) {
    final root =
        WidgetsBinding.instance.pipelineOwner.semanticsOwner?.rootSemanticsNode;
    if (root == null) {
      return;
    }

    final renderObjects = _getRenderObjectsWithSemantics();

    // Let checkers process new objects. This updates list of their issues
    checkers
        .where((checker) => checker.updateType.contains(updateType))
        .forEach((checker) => checker.didUpdateSemantics(renderObjects));
  }

  static List<RenderObject> _getRenderObjectsWithSemantics() {
    final renderObjects = <RenderObject>[];
    late final RenderObjectVisitor visitor;
    visitor = (child) {
      if (child.debugSemantics != null) {
        renderObjects.add(child);
      }

      child.visitChildrenForSemantics(visitor);
    };

    WidgetsBinding.instance.renderViewElement?.renderObject
        ?.visitChildrenForSemantics(visitor);

    return renderObjects;
  }

  void _logAccessibilityIssues(List<AccessibilityIssue> issues) {
    debugPrint('''
==========================
ACCESSIBILITY ISSUES FOUND
==========================
''');

    var i = 1;

    for (final issue in issues) {
      debugPrint('Accessibility issue $i: ${issue.message}\n');

      final creator = issue.getDebugCreator();
      if (creator != null) {
        debugPrint(creator.toWidgetCreatorString());
      }

      i++;
    }
  }
}

extension on DebugCreator {
  /// Returns a string description of the widget this [DebugCreator] is
  /// associated with, including the location in the source code the widget was
  /// created.
  String toWidgetCreatorString() {
    final diagnosticsNodes = debugTransformDebugCreator(
      [DiagnosticsDebugCreator(this)],
    );
    return diagnosticsNodes.map((e) => e.toStringDeep()).join('\n');
  }
}
