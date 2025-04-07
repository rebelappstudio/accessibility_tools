import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
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


Accessibility issue 2: Tap area of 10x10 is too small:
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
}
