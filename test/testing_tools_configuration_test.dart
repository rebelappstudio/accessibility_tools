import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:accessibility_tools/src/floating_action_buttons.dart';
import 'package:accessibility_tools/src/testing_tools/testing_tools_configuration.dart';
import 'package:accessibility_tools/src/testing_tools/testing_tools_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    "Disabling testing tools doesn't show the action button",
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          testingToolsConfiguration: TestingToolsConfiguration(
            enabled: true,
          ),
          child: SizedBox(),
        ),
      );
      await tester.pump();

      expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
      expect(find.byType(TestingToolsPanel), findsNothing);

      await tester.pumpWidget(
        const TestApp(
          testingToolsConfiguration: TestingToolsConfiguration(
            enabled: false,
          ),
          child: SizedBox(),
        ),
      );
      await tester.pump();

      expect(find.byType(AccessibilityToolsToggle), findsNothing);
      expect(find.byType(TestingToolsPanel), findsNothing);
    },
  );

  test('Invalid text scale values are not allowed', () {
    expect(
      const TestingToolsConfiguration(),
      const TestingToolsConfiguration(
        enabled: true,
        minTextScale: 0.1,
        maxTextScale: 10.0,
      ),
    );
    expect(
      const TestingToolsConfiguration(
        minTextScale: 1,
        maxTextScale: 15,
      ),
      const TestingToolsConfiguration(
        enabled: true,
        minTextScale: 1,
        maxTextScale: 15,
      ),
    );
    expect(
      () => TestingToolsConfiguration(
        minTextScale: -1,
      ),
      throwsAssertionError,
    );
    expect(
      () => TestingToolsConfiguration(
        minTextScale: -1,
        maxTextScale: 0,
      ),
      throwsAssertionError,
    );
    expect(
      () => TestingToolsConfiguration(
        minTextScale: 0,
      ),
      throwsAssertionError,
    );
    expect(
      () => TestingToolsConfiguration(
        maxTextScale: 1000,
      ),
      throwsAssertionError,
    );
    expect(
      () => TestingToolsConfiguration(
        minTextScale: 10,
        maxTextScale: 5,
      ),
      throwsAssertionError,
    );
  });

  test('Objects equality', () {
    expect(
      const TestingToolsConfiguration(
        minTextScale: 1,
        maxTextScale: 10,
      ),
      equals(
        const TestingToolsConfiguration(
          enabled: true,
          minTextScale: 1,
          maxTextScale: 10,
        ),
      ),
    );

    expect(
      const TestingToolsConfiguration(
        enabled: true,
        minTextScale: 1,
        maxTextScale: 10,
      ),
      isNot(
        equals(
          const TestingToolsConfiguration(
            enabled: false,
            minTextScale: 1,
            maxTextScale: 10,
          ),
        ),
      ),
    );

    expect(
      const TestingToolsConfiguration(
        enabled: true,
        minTextScale: 1,
        maxTextScale: 10,
      ),
      isNot(
        equals(
          const TestingToolsConfiguration(
            enabled: true,
            minTextScale: 0.5,
            maxTextScale: 50,
          ),
        ),
      ),
    );

    expect(
      const TestingToolsConfiguration(
        enabled: true,
        minTextScale: 1,
        maxTextScale: 10,
      ),
      isNot(
        equals(
          const TestingToolsConfiguration(
            enabled: true,
            minTextScale: 1,
            maxTextScale: 50,
          ),
        ),
      ),
    );

    expect(
      const TestingToolsConfiguration(
        enabled: true,
        minTextScale: 1,
        maxTextScale: 10,
      ).hashCode,
      isNot(
        const TestingToolsConfiguration(
          enabled: true,
          minTextScale: 1,
          maxTextScale: 11,
        ).hashCode,
      ),
    );
  });
}
