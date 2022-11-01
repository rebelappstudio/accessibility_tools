import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityIssue {
  AccessibilityIssue({
    required this.rect,
    required this.message,
    required this.node,
    required this.element,
  });

  final Rect rect;
  final String message;
  final SemanticsNode node;
  final Element? element;

  @override
  int get hashCode => node.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilityIssue &&
          runtimeType == other.runtimeType &&
          node == other.node &&
          message == other.message;
}
