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
        const TestApp(
          child: SizedBox(
            width: 100,
            child: Row(children: [Text('Testing')]),
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
          const TestApp(
            child: SizedBox(
              width: 100,
              child: Row(children: [Text('Testing')]),
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
Font sizes are calculated automatically by Flutter based on the OS setting.
Developers should make sure that layout has enough room to render all its
contents when the font sizes are increased.

The error often occurs when a Column or Row has a child widget that is not
constrained in its size. For example, a text widget in a container with fixed
height is not a good practice because it may overflow at larger font sizes:

SizedBox(
  height: 48,
  child: Text('Lorem ipsum dolor sit amet'),
),

Read more about large fonts: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#large-fonts
Read more about RenderFlex overflow: https://docs.flutter.dev/testing/common-errors#a-renderflex-overflowed
''';

      expect(log, expectedLog);
    },
  );
}
