import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    'Can check for both a too small tap area and no semantic label',
    (WidgetTester tester) async {
      final tapKey = UniqueKey();

      await tester.pumpWidget(
        TestApp(
          child: SizedBox(
            width: 10,
            height: 10,
            child: GestureDetector(
              key: tapKey,
              onTap: () {},
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(tapKey),
        tooltipMessage: '''
Tap area is missing a semantic label

Tap area of 10x10 is too small:
should be at least 48x48''',
      );
    },
  );

  testWidgets(
    'Prints warning for both a too small tap area and no semantic label',
    (WidgetTester tester) async {
      final tapKey = UniqueKey();

      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          TestApp(
            child: SizedBox(
              width: 10,
              height: 10,
              child: GestureDetector(key: tapKey, onTap: () {}),
            ),
          ),
        );

        await showAccessibilityIssues(tester);
      });

      final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Tap area is missing a semantic label

${getWidgetLocationDescription(tester, find.byKey(tapKey))}
Accessibility issue 2: Tap area of 10x10 is too small:
should be at least 48x48

${getWidgetLocationDescription(tester, find.byKey(tapKey))}
''';

      expect(log, expectedLog);
    },
  );
}
