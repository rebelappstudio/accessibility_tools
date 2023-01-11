import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets('Prints resolution guidance', (tester) async {
    final log = await recordDebugPrint(() async {
      await tester.pumpWidget(
        const TestApp(
          printResolutionGuidance: true,
          child: TextField(),
        ),
      );

      await showAccessibilityIssues(tester);
    });

    final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Text field is missing a label.

Semantic labels are used by screen readers to enable visually impaired users to
get spoken feedback about the contents of the screen and interact with the UI.

Consider adding a hint or a label to the text field widget. For example,

TextField(
  inputDecoration: InputDecoration(
    hint: 'This is hint',
  ),
),

Read more about screen readers: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#screen-readers

${getWidgetLocationDescription(tester, find.byType(TextField))}
''';

    expect(log, expectedLog);
  });

  testWidgets(
    "Doesn't print resolution guidance when turned off",
    (tester) async {
      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          const TestApp(
            printResolutionGuidance: false,
            child: TextField(),
          ),
        );

        await showAccessibilityIssues(tester);
      });

      final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Text field is missing a label.

${getWidgetLocationDescription(tester, find.byType(TextField))}
''';

      expect(log, expectedLog);
    },
  );
}
