import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

      if (!hasLabel && !_isFlutterInspectorButton(renderObject)) {
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

  /// Work-around for Flutter widget inspector select button not having a
  /// semantics label, and so being flagged as an accessibility issue.
  ///
  /// Can be removed once https://github.com/flutter/flutter/pull/117584 is
  /// released in Flutter stable.
  static bool _isFlutterInspectorButton(RenderObject renderObject) {
    final creator = renderObject.getCreatorElement();
    if (creator == null) {
      return false;
    }

    return creator
        .debugGetDiagnosticChain()
        .any((element) => element.widget is WidgetInspector);
  }
}

String semanticLabelMessage(String message) {
  return '''
Semantic labels are used by screen readers to enable visually impaired users to
get spoken feedback about the contents of the screen and interact with the UI.

$message

Read more about screen readers: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#screen-readers''';
}
