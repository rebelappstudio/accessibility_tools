import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';
import 'semantic_label_checker.dart';

/// Checks whether input widget has a label. Label must not be empty or blank
/// to pass this check.
///
/// This checker supports various input widgets: text fields, checkboxes, radio
/// buttons, switches.
class InputLabelChecker extends SemanticsNodeChecker {
  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (node.isMergedIntoParent ||
        node.isInvisible ||
        !node.getSemanticsData().isFormWidget) {
      return null;
    }

    final hasLabel = node.label.trim().isNotEmpty;
    if (hasLabel) return null;

    if (node.hasFlag(SemanticsFlag.isTextField)) {
      return _getTextFieldIssue(renderObject);
    } else if (node.hasFlag(SemanticsFlag.hasCheckedState)) {
      return _getCheckboxRadioIssue(renderObject);
    } else if (node.hasFlag(SemanticsFlag.hasToggledState)) {
      return _getSwitchIssue(renderObject);
    }

    return null;
  }

  AccessibilityIssue? _getTextFieldIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      message: 'Text field is missing a label.',
      renderObject: renderObject,
      resolutionGuidance: semanticLabelMessage('''
Consider adding a hint or a label to the text field widget. For example,

TextField(
  inputDecoration: InputDecoration(
    hint: 'This is hint',
  ),
),'''),
    );
  }

  AccessibilityIssue? _getCheckboxRadioIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      renderObject: renderObject,
      message: 'Control widget is missing a semantic label.',
      resolutionGuidance: semanticLabelMessage('''
Consider using widgets with title or label. For example, CheckboxTile instead
of Checkbox:

CheckboxListTile(
  title: Text('Show password)',
),'''),
    );
  }

  AccessibilityIssue? _getSwitchIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      renderObject: renderObject,
      message: 'Control widget is missing a semantic label.',
      resolutionGuidance: semanticLabelMessage('''
Consider using widgetts with title or label. For example, SwitchListTile instead
of Switch:

SwitchListTile(
  title: Text('Toggle visibility'),
),'''),
    );
  }
}
