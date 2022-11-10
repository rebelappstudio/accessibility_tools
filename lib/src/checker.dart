import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Checks for accessibility issues, updating whenever the semantic tree
/// changes.
class IssueChecker extends ChangeNotifier {
  IssueChecker(this.checkers);

  List<CheckerBase> checkers = [];

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

    final nodesMap = _getNodesMap();

    final newIssues = checkers
        .map((checker) => checker.getIssues(root, nodesMap))
        .expand((e) => e)
        .toList();

    final issuesHaveChanged = !listEquals(issues, newIssues);
    _setIssues(newIssues);

    if (newIssues.isNotEmpty && issuesHaveChanged) {
      _logAccessibilityIssues(newIssues, nodesMap);
    }
  }

  static Map<SemanticsNode, RenderObject> _getNodesMap() {
    final nodesMap = <SemanticsNode, RenderObject>{};
    late final RenderObjectVisitor visitor;
    visitor = (child) {
      if (child.debugSemantics != null) {
        nodesMap[child.debugSemantics!] = child;
      }

      child.visitChildrenForSemantics(visitor);
    };

    WidgetsBinding.instance.renderViewElement?.renderObject
        ?.visitChildrenForSemantics(visitor);

    return nodesMap;
  }

  void _logAccessibilityIssues(
    List<AccessibilityIssue> issues,
    Map<SemanticsNode, RenderObject> nodesMap,
  ) {
    debugPrint(
      '==========================\n'
      'ACCESSIBILITY ISSUES FOUND\n'
      '==========================\n',
    );

    int i = 0;
    for (final issue in issues) {
      final creator = nodesMap[issue.node]?.debugCreator;

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
