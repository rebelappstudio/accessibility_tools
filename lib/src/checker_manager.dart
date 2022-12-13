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
    for (final checker in checkers) {
      checker.addListener(_updateIssues);
    }
  }

  final Iterable<CheckerBase> checkers;

  /// A list of current accessibility issues.
  List<AccessibilityIssue> get issues => _issues;
  List<AccessibilityIssue> _issues = [];
  void _setIssues(List<AccessibilityIssue> issues) {
    _issues = issues;
    notifyListeners();
  }

  /// Called whenever the semantic tree updates.
  void update() {
    final root =
        WidgetsBinding.instance.pipelineOwner.semanticsOwner?.rootSemanticsNode;
    if (root == null) {
      return;
    }

    final renderObjects = _getRenderObjectsWithSemantics();

    for (final checker in checkers) {
      checker.didUpdateSemantics(renderObjects);
    }
  }

  void _updateIssues() {
    final newIssues = checkers.map((e) => e.issues).flattened.toList();
    final issuesHaveChanged = !listEquals(issues, newIssues);
    _setIssues(newIssues);

    if (newIssues.isNotEmpty && issuesHaveChanged) {
      _logAccessibilityIssues(newIssues);
    }
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
