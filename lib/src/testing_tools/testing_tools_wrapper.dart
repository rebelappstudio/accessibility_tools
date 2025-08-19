import 'package:flutter/material.dart';

import 'color_mode_simulation.dart';
import 'test_environment.dart';

/// Widget that applies [environment] to [child] using [MediaQuery], [Theme],
/// [Localizations] and debug flags
class TestingToolsWrapper extends StatelessWidget {
  /// Default constructor.
  const TestingToolsWrapper({
    super.key,
    required this.environment,
    required this.child,
  });

  /// Test environment to apply to the child.
  final TestEnvironment? environment;

  /// Widget to apply the test environment to.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context).copyWith(
      textScaler: environment?.textScaleFactor != null
          ? TextScaler.linear(environment!.textScaleFactor!)
          : null,
      boldText: environment?.boldText,
    );

    final themeData = Theme.of(context).copyWith(
      platform: environment?.targetPlatform,
      visualDensity: environment?.visualDensity,
    );

    Widget body = child;

    if (environment?.semanticsDebuggerEnabled ?? false) {
      body = SemanticsDebugger(child: body);
    }

    if (environment?.textDirection != null) {
      body = Directionality(
        textDirection: environment!.textDirection!,
        child: body,
      );
    }

    if (environment?.localeOverride != null) {
      body = Localizations.override(
        context: context,
        locale: environment?.localeOverride,
        child: body,
      );
    }

    if (environment?.colorModeSimulation != null) {
      body = ColorModeSimulator(
        simulation: environment!.colorModeSimulation!,
        child: body,
      );
    }

    return MediaQuery(
      data: mediaQueryData,
      child: Theme(data: themeData, child: body),
    );
  }
}
