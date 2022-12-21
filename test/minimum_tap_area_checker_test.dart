import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    'Shows warning for a small tap area on mobile',
    (WidgetTester tester) async {
      final tapKey = UniqueKey();

      await tester.pumpWidget(
        TestApp(
          child: SizedBox(
            width: 10,
            height: 10,
            child: GestureDetector(
              key: tapKey,
              child: const Text('Tap area'),
              onTap: () {},
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      debugDumpApp();

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(tapKey),
        tooltipMessage:
            'Tap area of 10x10 is too small:\nshould be at least 44x44',
      );
    },
  );

  testWidgets(
    'Prints console warning for a tap area that is too small',
    (WidgetTester tester) async {
      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          TestApp(
            child: ElevatedButton(
              child: const SizedBox(),
              onPressed: () {},
            ),
          ),
        );

        await showAccessibilityIssues(tester);
      });

      final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Tap area is a missing semantic label

${getWidgetLocationDescription(tester, find.byType(ElevatedButton))}
''';

      expect(log, expectedLog);
    },
  );

  testWidgets(
    "Doesn't show warning for tap area that's big enough",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ElevatedButton(
            child: Semantics(
              label: 'Label',
              child: const SizedBox(),
            ),
            onPressed: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(
        find.byWidgetPredicate((w) =>
            w is Tooltip &&
            w.message == 'Tap area is a missing semantic label'),
        findsNothing,
      );
    },
  );
}
