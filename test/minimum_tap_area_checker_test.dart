import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:accessibility_tools/src/checkers/minimum_tap_area_checker.dart';
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
          minimumTapAreas: const MinimumTapAreas(desktop: 0, mobile: 50),
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
          minimumTapAreas: const MinimumTapAreas(desktop: 100, mobile: 0),
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
      final tapKey = UniqueKey();
      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          TestApp(
            minimumTapAreas: const MinimumTapAreas(desktop: 48, mobile: 48),
            child: SizedBox(
              width: 20,
              height: 20,
              child: GestureDetector(
                key: tapKey,
                child: const Text('Tap area'),
                onTap: () {},
              ),
            ),
          ),
        );

        await showAccessibilityIssues(tester);
      });

      final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Tap area of 20x20 is too small:
should be at least 48x48

${getWidgetLocationDescription(tester, find.byKey(tapKey))}
Consider making the tap area bigger. For example, wrap the widget in a SizedBox:

InkWell(
  child: SizedBox.square(
    dimension: 48,
    child: child,
  ),
)

Icons have a size property:

Icon(
  Icons.wysiwyg,
  size: 48,
)
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

  testWidgets("Doesn't show warning for offscreen widget", (tester) async {
    tester.view.physicalSize = const Size(500, 500);

    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        minimumTapAreas: const MinimumTapAreas(desktop: 0, mobile: 100),
        child: Transform.translate(
          offset: const Offset(-10000, -10000),
          child: SizedBox(
            width: 50,
            height: 50,
            child: GestureDetector(
              key: key,
              child: const Text('Tap area'),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.accessibility_new), findsNothing);
    expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
  });

  testWidgets(
    'Shows warning for a small tap area when widget is partially visible',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 500);

      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          minimumTapAreas: const MinimumTapAreas(desktop: 0, mobile: 100),
          child: Transform.translate(
            offset: const Offset(-60, -60),
            child: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: GestureDetector(
                  key: key,
                  child: const Text('Tap area'),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);
      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage:
            'Tap area of 50x50 is too small:\nshould be at least 100x100',
      );
    },
  );

  testWidgets(
    'Shows warning for a small tap area when size is a floating point number',
    (WidgetTester tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          minimumTapAreas: const MinimumTapAreas(desktop: 0, mobile: 100),
          child: SizedBox(
            width: 99.3,
            height: 99.3,
            child: GestureDetector(
              key: key,
              child: const Text('Tap area'),
              onTap: () {},
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);
      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage:
            'Tap area of 99.30x99.30 is too small:\nshould be at least 100x100',
      );
    },
  );

  testWidgets(
    'Shows warning for a small tap area when size is an irrational number',
    (WidgetTester tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          minimumTapAreas: const MinimumTapAreas(desktop: 0, mobile: 100),
          child: SizedBox(
            width: 100 / 3,
            height: 100 / 6,
            child: GestureDetector(
              key: key,
              child: const Text('Tap area'),
              onTap: () {},
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);
      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage: 'Tap area of 33.33x16.67 is too small:'
            '\nshould be at least 100x100',
      );
    },
  );

  testWidgets(
    'Shows warning for a small tap area when pixel ratio is not an integer',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.333;

      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          minimumTapAreas: const MinimumTapAreas(desktop: 0, mobile: 100),
          child: SizedBox(
            width: 99,
            height: 99,
            child: GestureDetector(
              key: key,
              child: const Text('Tap area'),
              onTap: () {},
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);
      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage:
            'Tap area of 99x99 is too small:\nshould be at least 100x100',
      );
    },
  );

  testWidgets(
    "Doesn't show warnings for partially off-screen widgets inside scrollable",
    (tester) async {
      tester.view.devicePixelRatio = 1.0;

      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          TestApp(
            minimumTapAreas: const MinimumTapAreas(desktop: 25, mobile: 25),
            child: ListView(
              // Make sure big part of the blue widget is off-screen. The visible
              // part is still clickable and doesn't meet min tap area
              // requirements
              controller: ScrollController(initialScrollOffset: 80),
              padding: EdgeInsets.zero,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Semantics(
                    label: 'Label',
                    child: Container(
                      color: Colors.blue,
                      height: 100,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10000,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      });

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
      expect(log, isEmpty);
    },
  );

  test(
    'Formatted size is not too long (max 2 places after decimal point)',
    () {
      const format = MinimumTapAreaChecker.format;
      expect(format(100), '100');
      expect(format(1), '1');
      expect(format(0), '0');
      expect(format(0.00), '0');
      expect(format(100.00), '100');
      expect(format(100.01), '100.01');
      expect(format(100.10), '100.10');
      expect(format(99.99), '99.99');
      expect(format(99.999), '100');
      expect(format(100 / 3 /* 33.3(3) */), '33.33');
      expect(format(100 / 6 /* 16.6(6) */), '16.67');
    },
  );
}
