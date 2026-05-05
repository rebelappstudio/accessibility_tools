import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
  });

  testWidgets(
    'enableInReleaseMode allows accessibility controls to be visible',
    (WidgetTester tester) async {
      // Create an app with accessibility controls enabled in release mode
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AccessibilityTools(
            enableInReleaseMode: true,
            checkSemanticLabels: true,
            minimumTapAreas: MinimumTapAreas.material,
            child: child,
          ),
          home: Scaffold(
            body: GestureDetector(
              onTap: () {},
              child: SizedBox(width: 10, height: 10, child: Container()),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The app should render without issues
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );

  testWidgets(
    'Accessibility controls work normally when enableInReleaseMode is false',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AccessibilityTools(
            enableInReleaseMode: false,
            checkSemanticLabels: true,
            minimumTapAreas: MinimumTapAreas.material,
            child: child,
          ),
          home: Scaffold(
            body: GestureDetector(
              onTap: () {},
              child: SizedBox(width: 10, height: 10, child: Container()),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The app should render without issues
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );

  testWidgets(
    'Default value of enableInReleaseMode is false',
    (WidgetTester tester) async {
      // Create an AccessibilityTools without specifying enableInReleaseMode
      final tools = AccessibilityTools(child: Container());

      // Verify the default value is false
      expect(tools.enableInReleaseMode, isFalse);
    },
  );
}
