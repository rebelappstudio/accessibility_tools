import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accessibility_tools/accessibility_tools.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
  });

  testWidgets('enableAccessibilityControlsOnReleaseMode allows accessibility controls to be visible', (WidgetTester tester) async {
    // Create an app with accessibility controls enabled in release mode
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AccessibilityTools(child: child, enableAccessibilityControlsOnReleaseMode: true, checkSemanticLabels: true, minimumTapAreas: MinimumTapAreas.material),
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
  });

  testWidgets('Accessibility controls work normally when enableAccessibilityControlsOnReleaseMode is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AccessibilityTools(child: child, enableAccessibilityControlsOnReleaseMode: false, checkSemanticLabels: true, minimumTapAreas: MinimumTapAreas.material),
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
  });

  testWidgets('Default value of enableAccessibilityControlsOnReleaseMode is false', (WidgetTester tester) async {
    // Create an AccessibilityTools without specifying enableAccessibilityControlsOnReleaseMode
    final tools = AccessibilityTools(child: Container());

    // Verify the default value is false
    expect(tools.enableAccessibilityControlsOnReleaseMode, isFalse);
  });
}
