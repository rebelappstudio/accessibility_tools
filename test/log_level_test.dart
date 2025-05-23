import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
  });

  testWidgets('Can print all available logs', (tester) async {
    final log = await recordDebugPrint(() async {
      await tester.pumpWidget(
        const TestApp(logLevel: LogLevel.verbose, child: TextField()),
      );
      await tester.pumpAndSettle();
      await showAccessibilityIssues(tester);
    });

    final expectedLog =
        '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Text field is missing a label.

${getWidgetLocationDescription(tester, find.byType(TextField))}
Semantic labels are used by screen readers to enable visually impaired users to
get spoken feedback about the contents of the screen and interact with the UI.

Consider adding a hint or a label to the text field widget. For example:

  TextField(
    inputDecoration: InputDecoration(hint: 'This is hint'),
  )

Read more about screen readers: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#screen-readers
''';

    expect(log, expectedLog);
  });

  testWidgets('Can log warning messages only', (tester) async {
    final log = await recordDebugPrint(() async {
      await tester.pumpWidget(
        const TestApp(logLevel: LogLevel.warning, child: TextField()),
      );
      await tester.pumpAndSettle();
      await showAccessibilityIssues(tester);
    });

    final expectedLog =
        '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Text field is missing a label.

${getWidgetLocationDescription(tester, find.byType(TextField))}
''';

    expect(log, expectedLog);
  });

  testWidgets('Can disable logging', (tester) async {
    final log = await recordDebugPrint(() async {
      await tester.pumpWidget(
        const TestApp(
          logLevel: LogLevel.none,
          child: TextField(decoration: InputDecoration(hintText: null)),
        ),
      );
    });
    expect(log, isEmpty);
  });
}
