import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A possible accessibility issue that was discovered by a checker.
@immutable
class AccessibilityIssue {
  /// Default constructor.
  const AccessibilityIssue({
    required this.message,
    required this.resolutionGuidance,
    required this.renderObject,
  });

  /// Description of the issue.
  ///
  /// For example "Tappable area is missing a semantic label".
  final String message;

  /// Resolution guidance for the issue.
  ///
  /// May contain code example or another guidance on how to fix the issue.
  final String resolutionGuidance;

  /// Render object that this issue belongs to.
  final RenderObject renderObject;

  /// Semantics node that this issue belongs to.
  SemanticsNode? get semanticsNode => renderObject.debugSemantics;

  @override
  int get hashCode =>
      semanticsNode.hashCode ^ message.hashCode ^ resolutionGuidance.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilityIssue &&
          runtimeType == other.runtimeType &&
          semanticsNode == other.semanticsNode &&
          message == other.message &&
          resolutionGuidance == other.resolutionGuidance;

  /// Returns the debug creator of the render object that this issue belongs to.
  DebugCreator? getDebugCreator() {
    final creator = renderObject.debugCreator;

    if (creator is DebugCreator) {
      return creator;
    }

    return null;
  }
}
