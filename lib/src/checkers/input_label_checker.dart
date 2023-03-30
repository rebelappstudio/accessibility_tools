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
        node.hasFlag(SemanticsFlag.isHidden)) {
      return null;
    }

    final data = node.getSemanticsData();
    if (!data.isFormWidget) {
      return null;
    }

    final hasLabel = data.label.trim().isNotEmpty;
    if (hasLabel) return null;

    if (node.hasFlag(SemanticsFlag.isTextField)) {
      return _getTextFieldIssue(renderObject);
    } else if (node.hasFlag(SemanticsFlag.hasCheckedState)) {
      return _getCheckboxRadioIssue(renderObject);
    } else if (node.hasFlag(SemanticsFlag.hasToggledState)) {
      return _getSwitchIssue(renderObject);
    }

    return _getDefaultIssue(renderObject);
  }

  AccessibilityIssue _getDefaultIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      message: 'Control widget is missing a semantic label.',
      resolutionGuidance: '''
Consider adding a label to the widgets if it allows or using the Semantics
widget to provide a label:

  Semantics(
    label: 'Show password',
    child: MyWidget(),
  )

''',
      renderObject: renderObject,
    );
  }

  AccessibilityIssue _getTextFieldIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      message: 'Text field is missing a label.',
      renderObject: renderObject,
      resolutionGuidance: semanticLabelMessage('''
Consider adding a hint or a label to the text field widget. For example:

  TextField(
    inputDecoration: InputDecoration(hint: 'This is hint'),
  )'''),
    );
  }

  AccessibilityIssue _getCheckboxRadioIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      renderObject: renderObject,
      message: 'Control widget is missing a semantic label.',
      resolutionGuidance: semanticLabelMessage('''
Consider providing semantics label or using widgets with title or label. 
For example, screen reader users may have difficulties understanding what this
checkbox does:

  Checkbox()

Providing a label gives more context:

  Semantics(
    label: 'Show password',
    Checkbox(),
  )

Another option is to use CheckboxListTile instead:

  CheckboxListTile(
    title: Text('Show password')
  )

'''),
    );
  }

  AccessibilityIssue _getSwitchIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      renderObject: renderObject,
      message: 'Control widget is missing a semantic label.',
      resolutionGuidance: semanticLabelMessage('''
Consider using widgets with a title or label. For example, SwitchListTile
instead of Switch:

  SwitchListTile(
    title: Text('Toggle visibility'),
  )

'''),
    );
  }
}
