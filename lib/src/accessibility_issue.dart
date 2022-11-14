import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityIssue {
  AccessibilityIssue({
    required this.message,
    required this.renderObject,
  });

  final String message;
  final RenderObject renderObject;
  SemanticsNode? get semanticsNode => renderObject.debugSemantics;

  @override
  int get hashCode => semanticsNode.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilityIssue &&
          runtimeType == other.runtimeType &&
          semanticsNode == other.semanticsNode &&
          message == other.message;
}
