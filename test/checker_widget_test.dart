import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Builder doesn't prevent root widget changing", (
    WidgetTester tester,
  ) async {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AccessibilityTools(child: child),
        home: const Scaffold(body: Center(child: Text('one'))),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AccessibilityTools(child: child),
        home: const Scaffold(body: Center(child: Text('two'))),
      ),
    );

    expect(find.text('two'), findsOneWidget);
  });

  test('WarningBoxPainter repaints correctly', () {
    final painter = WarningBoxPainter(borderWidth: 1);

    expect(painter.shouldRepaint(WarningBoxPainter(borderWidth: 1)), isFalse);

    expect(painter.shouldRepaint(WarningBoxPainter(borderWidth: 2)), isTrue);
  });
}
