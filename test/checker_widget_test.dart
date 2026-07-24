import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

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

  testWidgets('Warning boxes align when embedded away from the root origin', (
    WidgetTester tester,
  ) async {
    const targetKey = Key('embedded-accessibility-target');
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            const SizedBox(width: 200),
            Expanded(
              child: AccessibilityTools(
                child: Scaffold(
                  body: Center(
                    child: IconButton(
                      key: targetKey,
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(targetKey),
      tooltipMessage: 'Tap area is missing a semantic label',
    );
  });

  testWidgets('Warning boxes include transforms in nested layouts', (
    WidgetTester tester,
  ) async {
    const targetKey = Key('transformed-accessibility-target');
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            const SizedBox(width: 200),
            Expanded(
              child: AccessibilityTools(
                child: Scaffold(
                  body: Center(
                    child: Transform.scale(
                      scale: 1.5,
                      child: IconButton(
                        key: targetKey,
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(targetKey),
      tooltipMessage: 'Tap area is missing a semantic label',
    );
  });

  test('WarningBoxPainter repaints correctly', () {
    final painter = WarningBoxPainter(borderWidth: 1);

    expect(painter.shouldRepaint(WarningBoxPainter(borderWidth: 1)), isFalse);

    expect(painter.shouldRepaint(WarningBoxPainter(borderWidth: 2)), isTrue);
  });
}
