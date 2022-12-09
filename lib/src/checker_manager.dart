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
    debugPrint(
      '==========================\n'
      'ACCESSIBILITY ISSUES FOUND\n'
      '==========================\n',
    );

    int i = 0;
    for (final issue in issues) {
      final creator = issue.renderObject.debugCreator;

      i++;

      debugPrint('Accessibility issue $i: ${issue.message}\n');

      if (creator is DebugCreator) {
        final chain = creator.element.debugGetDiagnosticChain();

        if (chain.length > 1) {
          debugPrint(
            '  Widget: ${creator.element.debugGetDiagnosticChain()[1]}\n'
            '  ${creator.element.describeOwnershipChain('Widget location')}\n',
          );
        }
      }
    }
  }
}
