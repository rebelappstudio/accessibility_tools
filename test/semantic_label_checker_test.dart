import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    'Shows warning for ElevatedButton without semantic label',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ElevatedButton(
            child: const SizedBox(),
            onPressed: () {},
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        finder: find.byType(ElevatedButton),
        tooltipMessage: 'Tap area is a missing semantic label',
      );
    },
  );

  testWidgets(
    'Shows warning for GestureDetector without semantic label',
    (WidgetTester tester) async {
      const gestureDetectorKey = Key('GestureDetector');

      await tester.pumpWidget(
        TestApp(
          child: GestureDetector(
            key: gestureDetectorKey,
            child: const SizedBox(width: 100, height: 100),
            onTap: () {},
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        finder: find.byKey(gestureDetectorKey),
        tooltipMessage: 'Tap area is a missing semantic label',
      );
    },
  );

  testWidgets(
    'Prints console warning for tap area without semantic label',
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
    "Doesn't show warning for ElevatedButton with semantic label",
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

class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => AccessibilityTools(child: child),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }
}
