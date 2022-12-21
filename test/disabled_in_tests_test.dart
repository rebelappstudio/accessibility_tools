import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets(
    'Does not show accessibility warnings when running from tests',
    (WidgetTester tester) async {
      // Ensure debug flag is not toggled
      expect(AccessibilityTools.debugRunCheckersInTests, isFalse);

      await tester.pumpWidget(
        TestApp(
          child: ElevatedButton(
            child: const SizedBox(),
            onPressed: () {},
          ),
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
    },
  );
}
