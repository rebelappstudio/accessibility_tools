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
        erroredWidgetFinder: find.byType(ElevatedButton),
        tooltipMessage: 'Tap area is missing a semantic label',
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
        erroredWidgetFinder: find.byKey(gestureDetectorKey),
        tooltipMessage: 'Tap area is missing a semantic label',
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

Accessibility issue 1: Tap area is missing a semantic label

${getWidgetLocationDescription(tester, find.byType(ElevatedButton))}
Semantic labels are used by screen readers to enable visually impaired users to
get spoken feedback about the contents of the screen and interact with the UI.

Consider adding a semantic label. For example,

InkWell(
  child: Icon(
    Icons.wifi,
    semanticLabel: 'Open Wi-Fi settings',
  ),
)

Read more about screen readers: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#screen-readers
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
      expect(
        find.byWidgetPredicate((w) =>
            w is Tooltip &&
            w.message == 'Tap area is missing a semantic label'),
        findsNothing,
      );
    },
  );

  testWidgets(
    "Doesn't show warning for Flutter widget inspector button",
    (WidgetTester tester) async {
      // This test can be removed when this PR is released in Flutter stable:
      // https://github.com/flutter/flutter/pull/117584

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AccessibilityTools(child: child),
          home: WidgetInspector(
            child: const Scaffold(),
            selectButtonBuilder: (context, onPressed) {
              return FloatingActionButton(
                onPressed: onPressed,
                child: const Icon(Icons.search),
              );
            },
          ),
        ),
      );

      // Tap the scaffold to show the inspector button
      await tester.tap(find.byType(Scaffold), warnIfMissed: false);
      await tester.pump();

      // Verify inspector button is shown
      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.pump();

      // Verify no accessibility issues found
      expect(find.byIcon(Icons.accessibility_new), findsNothing);
    },
  );
}
