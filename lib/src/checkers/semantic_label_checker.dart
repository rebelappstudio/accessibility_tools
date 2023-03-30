import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../accessibility_issue.dart';
import 'checker_base.dart';

class SemanticLabelChecker extends SemanticsNodeChecker {
  @override
  AccessibilityIssue? checkNode(SemanticsNode node, RenderObject renderObject) {
    if (node.isMergedIntoParent ||
        node.isInvisible ||
        node.hasFlag(ui.SemanticsFlag.isHidden)) {
      return null;
    }

    final data = node.getSemanticsData();
    if (data.isTappable && !data.isFormWidget) {
      final hasLabel =
          data.label.trim().isNotEmpty || data.tooltip.trim().isNotEmpty;

      if (!hasLabel) {
        return AccessibilityIssue(
          message: 'Tap area is missing a semantic label',
          resolutionGuidance: semanticLabelMessage('''
Consider adding a semantic label. For example,

InkWell(
  child: Icon(
    Icons.wifi,
    semanticLabel: 'Open Wi-Fi settings',
  ),
)'''),
          renderObject: renderObject,
        );
      }
    }

    return null;
  }
}

String semanticLabelMessage(String message) {
  return '''
Semantic labels are used by screen readers to enable visually impaired users to
get spoken feedback about the contents of the screen and interact with the UI.

$message

Read more about screen readers: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#screen-readers''';
}
