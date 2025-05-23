import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:accessibility_tools/src/floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets('Does not show accessibility warnings when running from tests', (
    WidgetTester tester,
  ) async {
    // Ensure debug flag is not toggled
    expect(AccessibilityTools.debugRunCheckersInTests, isFalse);

    await tester.pumpWidget(
      TestApp(
        child: ElevatedButton(child: const SizedBox(), onPressed: () {}),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Verify no overlay inserted by checker
    expect(find.byType(CheckerOverlay), findsNothing);

    // Verify no accessibility warning icon is shown
    expect(find.byIcon(Icons.accessibility_new), findsNothing);

    // Verify button is rendered
    expect(find.byType(SizedBox), findsOneWidget);
  });

  test(
    'debugIgnoreTapAreaIssuesInTools set to true by default and can be changed',
    () {
      // Verify default value
      expect(AccessibilityTools.debugIgnoreTapAreaIssuesInTools, isTrue);

      AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
      expect(AccessibilityTools.debugIgnoreTapAreaIssuesInTools, isFalse);
    },
  );

  testWidgets(
    '''Ignores own tap area size issues when debugIgnoreTapAreaIssuesInTools set to true''',
    (tester) async {
      AccessibilityTools.debugRunCheckersInTests = true;
      AccessibilityTools.debugIgnoreTapAreaIssuesInTools = true;

      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => AccessibilityTools(
              minimumTapAreas: const MinimumTapAreas(mobile: 100, desktop: 100),
              logLevel: LogLevel.warning,
              child: child,
            ),
            home: const SizedBox(),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(AccessibilityIssuesToggle), findsNothing);

        await tester.tap(find.byType(AccessibilityToolsToggle));
        await tester.pumpAndSettle();
      });

      expect(log, isEmpty);
    },
  );

  testWidgets(
    '''Does not ignore own tap area size issues when debugIgnoreTapAreaIssuesInTools set to false''',
    (tester) async {
      AccessibilityTools.debugRunCheckersInTests = true;
      AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;

      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => AccessibilityTools(
              minimumTapAreas: const MinimumTapAreas(mobile: 100, desktop: 100),
              logLevel: LogLevel.warning,
              child: child,
            ),
            home: const SizedBox(),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(AccessibilityIssuesToggle), findsOneWidget);

        await tester.tap(find.byType(AccessibilityToolsToggle));
        await tester.pumpAndSettle();
      });

      // Issue caused by Accessibility tools' buttons being too small
      expect(
        log,
        contains('Accessibility issue 1: Tap area of 48x48 is too small'),
      );

      // Issue caused by the testing tools panel buttons being too small
      expect(log, contains('Accessibility issue 24: Tap area of'));
    },
  );
}
