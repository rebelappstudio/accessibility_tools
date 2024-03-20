import 'package:accessibility_tools/src/testing_tools/color_mode_simulation.dart';
import 'package:accessibility_tools/src/testing_tools/test_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TestEnvironment comparison works', () {
    expect(const TestEnvironment(), equals(const TestEnvironment()));
    expect(
      const TestEnvironment(
        textScaleFactor: 1.0,
        boldText: true,
        targetPlatform: TargetPlatform.android,
        visualDensity: VisualDensity.comfortable,
        localeOverride: Locale('en', 'US'),
        textDirection: TextDirection.ltr,
        semanticsDebuggerEnabled: true,
        colorModeSimulation: ColorModeSimulation.deuteranopia,
      ),
      equals(
        const TestEnvironment(
          textScaleFactor: 1.0,
          boldText: true,
          targetPlatform: TargetPlatform.android,
          visualDensity: VisualDensity.comfortable,
          localeOverride: Locale('en', 'US'),
          textDirection: TextDirection.ltr,
          semanticsDebuggerEnabled: true,
          colorModeSimulation: ColorModeSimulation.deuteranopia,
        ),
      ),
    );
    expect(
      const TestEnvironment(boldText: true),
      isNot(const TestEnvironment(boldText: false)),
    );
    expect(
      const TestEnvironment(
        textScaleFactor: 2.0,
        boldText: true,
        targetPlatform: TargetPlatform.android,
        visualDensity: VisualDensity.comfortable,
        localeOverride: Locale('en', 'US'),
        textDirection: TextDirection.ltr,
        semanticsDebuggerEnabled: true,
        colorModeSimulation: ColorModeSimulation.deuteranopia,
      ),
      isNot(
        const TestEnvironment(
          textScaleFactor: 1.0,
          boldText: true,
          targetPlatform: TargetPlatform.android,
          visualDensity: VisualDensity.comfortable,
          localeOverride: Locale('en', 'US'),
          textDirection: TextDirection.ltr,
          semanticsDebuggerEnabled: true,
          colorModeSimulation: ColorModeSimulation.deuteranopia,
        ),
      ),
    );
    expect(
      const TestEnvironment(boldText: true).hashCode,
      isNot(const TestEnvironment(boldText: false).hashCode),
    );
    expect(
      const TestEnvironment(boldText: true).hashCode,
      equals(const TestEnvironment(boldText: true).hashCode),
    );
    expect(
      const TestEnvironment(boldText: true).toString(),
      equals(const TestEnvironment(boldText: true).toString()),
    );
  });
}
