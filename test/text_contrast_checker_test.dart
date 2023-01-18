import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    "Doesn't show warning for widgets without text",
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          checkTextContrast: true,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.white,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.black12,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.accessibility_new), findsNothing);
    },
  );

  testWidgets(
    "Doesn't show warning for contrast text",
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          checkTextContrast: true,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.white,
            child: const Text(
              'Lorem ipsum',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.accessibility_new), findsNothing);
    },
  );

  // FIXME fix this test
  // TODO add test: white text on black background
  // TODO add test: debug console output
  // testWidgets('Shows warning for low contrast text', (tester) async {
  //   await tester.pumpWidget(
  //     const TestApp(
  //       checkTextContrast: true,
  //       child: ColoredBox(
  //         color: Colors.white,
  //         child: Text(
  //           'Light gray text on white background',
  //           style: TextStyle(color: Colors.black12),
  //         ),
  //       ),
  //     ),
  //   );

  //   await tester.pumpAndSettle(const Duration(milliseconds: 500));
  //   await showAccessibilityIssues(tester);
  //   expectAccessibilityWarning(
  //     tester,
  //     erroredWidgetFinder: find.byType(Text),
  //   tooltipMessage: 'Expected contrast ratio of at least 4.5 but found 1.04',
  //   );
  // });
}
