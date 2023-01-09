import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

/// Checks whether text field has a label. Label must not be empty or blank
/// to pass this check.
///
/// There are several way to set a text label of a [TextField]:
/// * hintText property
/// * labelText property
/// * label property (any widget)
/// * label widget's label e.g. [Icon] with semantic label
///
/// Nodes with [SemanticsFlag.isTextField] are considered text fields.
class TextFieldLabelChecker extends SemanticsNodeChecker {
  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (!node.hasFlag(SemanticsFlag.isTextField)) {
      return null;
    }

    String? message;
    final label = node.label;
    if (label.isEmpty) {
      message = 'Text field is missing a label';
    } else if (label.trim().isEmpty) {
      message = "Text field's label is blank";
    }

    if (message != null) {
      return AccessibilityIssue(
        message: message,
        renderObject: renderObject,
      );
    }

    return null;
  }
}
