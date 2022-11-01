import 'dart:async';
import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class IssueChecker extends ChangeNotifier {
  late final Timer _timer;

  IssueChecker(this.checkers) {
    _pipelineOwner.ensureSemantics();
    // _waitForSemanticsOwner();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      update();
    });
  }

  List<CheckerBase> checkers = [];

  PipelineOwner get _pipelineOwner => WidgetsBinding.instance.pipelineOwner;

  void initialize() {
    _pipelineOwner.ensureSemantics();
    _waitForSemanticsOwner();
  }

  void _waitForSemanticsOwner() {
    final semanticsOwner = _pipelineOwner.semanticsOwner;

    if (semanticsOwner != null) {
      // semanticsOwner.addListener(_onSemanticsChanged);
      // update();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _waitForSemanticsOwner();
      });
    }
  }

  List<AccessibilityIssue> _issues = [];
  List<AccessibilityIssue> get issues => _issues;
  void _setIssues(List<AccessibilityIssue> issues) {
    _issues = issues;
    notifyListeners();
  }

  void update() {
    final root = _pipelineOwner.semanticsOwner?.rootSemanticsNode;
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
