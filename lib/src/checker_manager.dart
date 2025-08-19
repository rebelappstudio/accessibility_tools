import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'accessibility_issue.dart';
import 'accessibility_tools.dart';
import 'checkers/checker_base.dart';

/// Manages the checkers and updates the accessibility issues.
///
/// Checks for accessibility issues, updating whenever the semantic tree
/// changes.
class CheckerManager extends ChangeNotifier {
  /// Default constructor.
  CheckerManager({required this.checkers, required this.logLevel});

  /// A list of enabled checkers.
  final Iterable<CheckerBase> checkers;

  /// Log level for the accessibility issues.
  final LogLevel logLevel;

  /// A list of current accessibility issues.
  List<AccessibilityIssue> get issues => _issues;

  /// A list of current accessibility issues.
  List<AccessibilityIssue> _issues = [];

  /// Sets the issues and notifies listeners.
  void _setIssues(List<AccessibilityIssue> issues) {
    _issues = issues;
    notifyListeners();
  }

  /// Notifies checkers to update their issues and updates the issues.
  ///
  /// Called whenever the semantic tree updates (time to check for new issues
  /// and issue updates).
  void update() {
    final renderObjects = _getRenderObjectsWithSemantics();

    for (final checker in checkers) {
      checker.didUpdateSemantics(renderObjects);
    }

    _updateIssues();
  }

  /// Updates the accessibility issues.
  void _updateIssues() {
    final newIssues = checkers.map((e) => e.issues).flattened.toList();
    final issuesHaveChanged = !listEquals(issues, newIssues);

    _setIssues(newIssues);

    if (newIssues.isNotEmpty && issuesHaveChanged) {
      _logAccessibilityIssues(logLevel, newIssues);
    }
  }

  /// Returns a list of all render objects that contain semantics information.
  static List<RenderObject> _getRenderObjectsWithSemantics() {
    final renderObjects = <RenderObject>[];
    late final RenderObjectVisitor visitor;
    visitor = (child) {
      if (child.debugSemantics != null) {
        renderObjects.add(child);
      }

      child.visitChildrenForSemantics(visitor);
    };

    WidgetsBinding.instance.rootElement?.renderObject
        ?.visitChildrenForSemantics(visitor);

    return renderObjects;
  }

  void _logAccessibilityIssues(
    LogLevel logLevel,
    List<AccessibilityIssue> issues,
  ) {
    if (logLevel == LogLevel.none) return;

    debugPrint('''
==========================
ACCESSIBILITY ISSUES FOUND
==========================
''');

    var i = 1;

    for (final issue in issues) {
      if (i > 1) debugPrint('\n');
      debugPrint('Accessibility issue $i: ${issue.message}\n');

      final creator = issue.getDebugCreator();
      if (creator != null) {
        debugPrint(creator.toWidgetCreatorString());
      }

      if (logLevel == LogLevel.verbose) {
        debugPrint(issue.resolutionGuidance);
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
    final diagnosticsNodes = debugTransformDebugCreator([
      DiagnosticsDebugCreator(this),
    ]);
    return diagnosticsNodes.map((e) => e.toStringDeep()).join('\n');
  }
}
