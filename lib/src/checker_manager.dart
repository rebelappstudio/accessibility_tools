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
      final creator = issue.getDebugCreator();

      i++;

      debugPrint('Accessibility issue $i: ${issue.message}\n');

      if (creator != null) {
        final diagnosticsNodes =
            debugTransformDebugCreator([DiagnosticsDebugCreator(creator)]);
        debugPrint(diagnosticsNodes.map((e) => e.toStringDeep()).join('\n'));
      }
    }
  }
}

CreationLocation? getCreationLocation(Element element) {
  // debugIsWidgetLocalCreation
  final node = element.widget.toDiagnosticsNode();
  final inspectorDelegate = InspectorSerializationDelegate(
    service: WidgetInspectorService.instance,
  );
  final props = inspectorDelegate.additionalNodeProperties(node);
  final location = props['creationLocation'];
  if (location is Map<String, Object?>) {
    return CreationLocation.fromJsonMap(
      props['creationLocation'] as Map<String, Object?>,
    );
  }

  return null;
}

class CreationLocation {
  const CreationLocation({
    required this.file,
    required this.line,
    required this.column,
    this.name,
  });

  /// File path of the location.
  final String file;

  /// 1-based line number.
  final int line;

  /// 1-based column number.
  final int column;

  /// Optional name of the parameter or function at this location.
  final String? name;

  static CreationLocation fromJsonMap(Map<String, Object?> json) {
    return CreationLocation(
      file: json['file'] as String,
      line: json['line'] as int,
      column: json['column'] as int,
      name: json['name'] as String?,
    );
  }

  @override
  String toString() {
    return [file, line, column].join(':');
  }
}
