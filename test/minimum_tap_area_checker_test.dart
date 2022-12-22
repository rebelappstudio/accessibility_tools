import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/foundation.dart';
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
          minTapAreas: const MinimumTapAreas(desktop: 0, mobile: 50),
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

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(tapKey),
        tooltipMessage:
            'Tap area of 10x10 is too small:\nshould be at least 50x50',
      );
    },
  );

  testWidgets(
    'Shows warning for a small tap area on desktop',
    (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final tapKey = UniqueKey();

      await tester.pumpWidget(
        TestApp(
          minTapAreas: const MinimumTapAreas(desktop: 100, mobile: 0),
          child: SizedBox(
            width: 50,
            height: 50,
            child: GestureDetector(
              key: tapKey,
              child: const Text('Tap area'),
              onTap: () {},
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(tapKey),
        tooltipMessage:
            'Tap area of 50x50 is too small:\nshould be at least 100x100',
      );

      debugDefaultTargetPlatformOverride = null;
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

Accessibility issue 1: Tap area is missing a semantic label

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
            w.message == 'Tap area is missing a semantic label'),
        findsNothing,
      );
    },
  );

  test('MinimumTapAreas.forPlatform returns correct values per platform', () {
    const desktopValue = 10.0;
    const mobileValue = 20.0;
    const tapAreas = MinimumTapAreas(
      desktop: desktopValue,
      mobile: mobileValue,
    );

    expect(tapAreas.forPlatform(TargetPlatform.iOS), mobileValue);
    expect(tapAreas.forPlatform(TargetPlatform.android), mobileValue);
    expect(tapAreas.forPlatform(TargetPlatform.fuchsia), mobileValue);

    expect(tapAreas.forPlatform(TargetPlatform.macOS), desktopValue);
    expect(tapAreas.forPlatform(TargetPlatform.windows), desktopValue);
    expect(tapAreas.forPlatform(TargetPlatform.linux), desktopValue);
  });
}
