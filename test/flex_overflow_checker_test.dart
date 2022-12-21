import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    'Shows warning for overflowing text',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: SizedBox(
            width: 100,
            child: Row(children: const [Text('Testing')]),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byType(Row),
        tooltipMessage: 'This RenderFlex will overflow at larger font sizes.',
      );
    },
  );

  testWidgets(
    'Prints console warning for overflowing text',
    (WidgetTester tester) async {
      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          TestApp(
            child: SizedBox(
              width: 100,
              child: Row(children: const [Text('Testing')]),
            ),
          ),
        );

        await showAccessibilityIssues(tester);
      });

      final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: This RenderFlex will overflow at larger font sizes.

${getWidgetLocationDescription(tester, find.byType(Row))}
''';

      expect(log, expectedLog);
    },
  );
}
