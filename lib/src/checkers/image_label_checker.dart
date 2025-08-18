import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

/// Checks whether image widgets have a label. Label must not be empty or blank
/// to pass this check.
class ImageLabelChecker extends SemanticsNodeChecker {
  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (node.isMergedIntoParent ||
        node.isInvisible ||
        node.flagsCollection.isHidden) {
      return null;
    }

    final data = node.getSemanticsData();
    if (!data.isImage) return null;

    final hasLabel = data.label.trim().isNotEmpty;
    if (hasLabel) return null;

    return _getImageIssue(renderObject);
  }

  AccessibilityIssue _getImageIssue(RenderObject renderObject) {
    return AccessibilityIssue(
      message: 'Image widget is missing a semantic label.',
      resolutionGuidance: '''
Consider adding a semantic label to the image if it allows or using the Semantics
widget to provide a label:

  Image.asset(
    'assets/image.png',
    semanticLabel: 'Show password',
  )

''',
      renderObject: renderObject,
    );
  }
}
