import 'package:accessibility_tools/src/accessibility_issue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Accessibility issues are equal with same semantics node and message',
      () {
    final semanticsNode = SemanticsNode();

    final issue1 = AccessibilityIssue(
      message: 'message',
      renderObject: TestRenderObject(semanticsNode),
    );

    final issue2 = AccessibilityIssue(
      message: 'message',
      renderObject: TestRenderObject(semanticsNode),
    );

    expect(issue1, issue2);
    expect(issue1.hashCode, issue2.hashCode);
  });

  test('Accessibility issues are not equal with different semantics nodes', () {
    final issue1 = AccessibilityIssue(
      message: 'message',
      renderObject: TestRenderObject(SemanticsNode()),
    );

    final issue2 = AccessibilityIssue(
      message: 'message',
      renderObject: TestRenderObject(SemanticsNode()),
    );

    expect(issue1, isNot(issue2));
    expect(issue1.hashCode, isNot(issue2.hashCode));
  });

  test('Accessibility issues are not equal with different messages', () {
    final semanticsNode = SemanticsNode();

    final issue1 = AccessibilityIssue(
      message: 'message 1',
      renderObject: TestRenderObject(semanticsNode),
    );

    final issue2 = AccessibilityIssue(
      message: 'message 2',
      renderObject: TestRenderObject(semanticsNode),
    );

    expect(issue1, isNot(issue2));
    expect(issue1.hashCode, isNot(issue2.hashCode));
  });
}

class TestRenderObject extends RenderObject {
  TestRenderObject(this.debugSemantics);

  @override
  final SemanticsNode debugSemantics;

  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  Rect get paintBounds => throw UnimplementedError();

  @override
  void performLayout() {}

  @override
  void performResize() {}

  @override
  Rect get semanticBounds => throw UnimplementedError();
}
